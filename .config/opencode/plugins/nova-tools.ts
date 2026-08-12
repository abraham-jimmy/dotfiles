import path from "node:path"
import { spawn } from "node:child_process"
import { homedir } from "node:os"
import type { Plugin, ToolContext } from "@opencode-ai/plugin"
import { tool } from "@opencode-ai/plugin"

const maxOutputBytes = 4 * 1024 * 1024
const commandTimeoutMs = 120_000

const productPaths = [
  ".ai-nova/product-spec.md",
  ".ai-nova/PRODUCT-INPUT.md",
  ".ai-nova/INBOX.md",
]

const projectScriptAgents = [
  "nova-product-steward",
  "nova-project-planner",
  "nova-readonly",
  "nova-setup-steward",
  "nova-task-worker",
  "nova-validator",
]

async function runResult(command: string[], cwd: string, signal?: AbortSignal) {
  return await new Promise<{ stdout: string; stderr: string; exitCode: number }>((resolve, reject) => {
    const child = spawn(command[0], command.slice(1), { cwd, signal })
    let stdout = ""
    let stderr = ""
    let outputBytes = 0
    let settled = false
    let timer: ReturnType<typeof setTimeout>
    const fail = (error: Error) => {
      if (settled) return
      settled = true
      clearTimeout(timer)
      reject(error)
    }
    timer = setTimeout(() => {
      child.kill()
      fail(new Error(`${command[0]} timed out after ${commandTimeoutMs / 1000} seconds`))
    }, commandTimeoutMs)
    const append = (target: "stdout" | "stderr", chunk: Buffer) => {
      outputBytes += chunk.length
      if (outputBytes > maxOutputBytes) {
        child.kill()
        fail(new Error(`${command[0]} output exceeded ${maxOutputBytes / 1024 / 1024} MiB`))
        return
      }
      if (target === "stdout") stdout += chunk
      else stderr += chunk
    }
    child.stdout.on("data", (chunk: Buffer) => append("stdout", chunk))
    child.stderr.on("data", (chunk: Buffer) => append("stderr", chunk))
    child.on("error", fail)
    child.on("close", (exitCode) => {
      if (settled) return
      settled = true
      clearTimeout(timer)
      resolve({ stdout, stderr, exitCode: exitCode ?? 1 })
    })
  })
}

async function run(command: string[], cwd: string, signal?: AbortSignal) {
  const result = await runResult(command, cwd, signal)
  if (result.exitCode !== 0) {
    throw new Error(result.stderr.trim() || `${command[0]} exited with ${result.exitCode}`)
  }
  return result.stdout.trim()
}

function literalPathspec(relative: string) {
  return `:(literal)${relative}`
}

async function repositoryRoot(input: string | undefined, context: ToolContext) {
  const candidate = input ? path.resolve(context.directory, input) : context.worktree
  if (path.resolve(candidate) !== path.resolve(context.worktree)) {
    await context.ask({
      permission: "external_directory",
      patterns: [candidate],
      always: [],
      metadata: { agent: context.agent, repository: candidate },
    })
  }
  const root = path.resolve(await run(["git", "rev-parse", "--show-toplevel"], candidate, context.abort))
  if (root !== path.resolve(context.worktree) && root !== path.resolve(candidate)) {
    await context.ask({
      permission: "external_directory",
      patterns: [root],
      always: [],
      metadata: { agent: context.agent, repository: root },
    })
  }
  return root
}

function projectPath(root: string, input: string) {
  const absolute = path.resolve(root, input)
  const relative = path.relative(root, absolute)
  if (!relative || relative.startsWith("..") || path.isAbsolute(relative)) {
    throw new Error(`Path must stay inside the project: ${input}`)
  }
  return relative
}

function pathAllowed(agent: string, relative: string) {
  if (agent === "nova-product-steward") {
    return productPaths.includes(relative) || relative.startsWith(".ai-nova/product-changes/")
  }
  if (["nova-project-planner", "nova-setup-steward", "nova-validator"].includes(agent)) {
    return relative.startsWith(".ai-nova/") && relative !== ".ai-nova/product-spec.md"
  }
  if (agent === "nova-task-worker") {
    return !/(^|\/)\.ai-nova\/product-spec\.md$/.test(relative)
  }
  return false
}

function actionAllowed(agent: string, action: string) {
  if (agent === "nova-readonly") return action === "status"
  return [
    "nova-product-steward",
    "nova-project-planner",
    "nova-setup-steward",
    "nova-validator",
    "nova-task-worker",
  ].includes(agent)
}

export default (async () => ({
  tool: {
    nova_git: tool({
      description: "Read NOVA Git metadata or perform an explicitly confirmed, agent-scoped stage/commit.",
      args: {
        action: tool.schema.enum(["status", "diff", "staged_diff", "stage", "commit"]),
        repository: tool.schema.string().optional(),
        paths: tool.schema.array(tool.schema.string()).optional(),
        message: tool.schema.string().optional(),
      },
      async execute(args, context) {
        if (!actionAllowed(context.agent, args.action)) {
          throw new Error(`${context.agent} may not run nova_git ${args.action}`)
        }
        const root = await repositoryRoot(args.repository, context)

        if (args.action === "status") {
          return (await run(["git", "status", "--short", "--untracked-files=all"], root, context.abort)) || "Clean"
        }
        if (args.action === "diff" || args.action === "staged_diff") {
          if (context.agent !== "nova-task-worker" && !args.paths?.length) {
            throw new Error(`${context.agent} must provide explicit documentation paths for diff`)
          }
          const command = ["git", "diff"]
          if (args.action === "staged_diff") command.push("--cached")
          if (args.paths?.length) {
            const paths = args.paths.map((item) => projectPath(root, item))
            for (const item of paths) {
              if (!pathAllowed(context.agent, item)) throw new Error(`${context.agent} may not read diff for ${item}`)
            }
            command.push("--", ...paths.map(literalPathspec))
          }
          return (await run(command, root, context.abort)) || "No diff"
        }
        if (args.action === "stage") {
          if (!args.paths?.length) throw new Error("Stage requires explicit paths")
          const paths = args.paths.map((item) => projectPath(root, item))
          for (const item of paths) {
            if (!pathAllowed(context.agent, item)) throw new Error(`${context.agent} may not stage ${item}`)
          }
          const existing = await run(["git", "diff", "--cached", "--name-only"], root, context.abort)
          if (existing) throw new Error(`Pre-existing staged changes:\n${existing}`)
          await context.ask({
            permission: "nova_git_stage",
            patterns: paths,
            always: [],
            metadata: { agent: context.agent, paths },
          })
          await run(["git", "add", "-A", "--", ...paths.map(literalPathspec)], root, context.abort)
          return (await run(["git", "diff", "--cached"], root, context.abort)) || "Nothing staged"
        }

        if (!args.message?.trim()) throw new Error("Commit requires a message")
        const stagedResult = await runResult(["git", "diff", "--cached", "--name-only", "--no-renames", "-z"], root, context.abort)
        if (stagedResult.exitCode !== 0) throw new Error(stagedResult.stderr.trim() || "Unable to inspect staged paths")
        const staged = stagedResult.stdout.split("\0").filter(Boolean)
        if (!staged.length) throw new Error("Nothing is staged")
        for (const item of staged) {
          if (!pathAllowed(context.agent, item)) throw new Error(`${context.agent} may not commit ${item}`)
        }
        await context.ask({
          permission: "nova_git_commit",
          patterns: [args.message.trim()],
          always: [],
          metadata: { agent: context.agent, staged },
        })
        await run(["git", "commit", "-m", args.message.trim()], root, context.abort)
        const hash = await run(["git", "rev-parse", "--short", "HEAD"], root, context.abort)
        return `Created ${hash}: ${args.message.trim()}`
      },
    }),
    nova_project_check: tool({
      description: "Run NOVA's deterministic structure checker for the current or explicitly selected repository.",
      args: {
        repository: tool.schema.string().optional(),
        verbose: tool.schema.boolean().optional(),
      },
      async execute(args, context) {
        if (!projectScriptAgents.includes(context.agent)) {
          throw new Error(`${context.agent} may not run the NOVA structure checker`)
        }
        const root = await repositoryRoot(args.repository, context)
        const script = path.join(homedir(), ".config/ai/workflows/nova/scripts/nova-project-check.sh")
        const command = [script]
        if (args.verbose) command.push("--verbose")
        command.push(root)
        const result = await runResult(command, root, context.abort)
        if (result.exitCode > 1) throw new Error(result.stderr.trim() || `Structure check exited with ${result.exitCode}`)
        return result.stdout.trim()
      },
    }),
    nova_status: tool({
      description: "Run NOVA's deterministic project status report for the current or explicitly selected repository.",
      args: {
        repository: tool.schema.string().optional(),
      },
      async execute(args, context) {
        if (!projectScriptAgents.includes(context.agent)) {
          throw new Error(`${context.agent} may not run the NOVA status report`)
        }
        const root = await repositoryRoot(args.repository, context)
        const script = path.join(homedir(), ".config/ai/workflows/nova/scripts/nova-status.sh")
        const result = await runResult([script, root], root, context.abort)
        if (result.exitCode > 1) throw new Error(result.stderr.trim() || `Status report exited with ${result.exitCode}`)
        return result.stdout.trim()
      },
    }),
  },
})) satisfies Plugin
