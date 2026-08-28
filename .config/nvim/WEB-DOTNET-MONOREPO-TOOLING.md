# Neovim Tooling Requirements: TypeScript Web-Component + .NET Monorepos

Status: requirements specification, written 2026-08-28.
Audience: an LLM (or human) that will install and maintain this Neovim configuration.

This document describes **what tooling is needed and why**, derived from a concrete set of
work repositories. It is deliberately free of employer-specific names, hosts, feed URLs and
package names. Repository-local configuration (lint configs, formatter configs, SDK pins,
CI rules) stays in the repositories and always wins over anything set globally here.

Companion document: `LANGUAGE-TOOLING.md` (background research on tool choices).
This document is the concrete, decided plan; `LANGUAGE-TOOLING.md` is the survey.

---

## 1. How this config is structured (contract to respect)

Neovim `0.13.0-dev`, plugins managed by the built-in `vim.pack`, loaded explicitly from
`lua/pack/init.lua`. There is **no Mason and no lazy.nvim** in the active setup.

Language tooling is data, not code-in-plugins. Each file `lua/lang/<name>.lua` returns:

```lua
local M = {}

function M.tooling()
  return {
    lsp = { <server_name> = { <vim.lsp.Config fields> } },
    linters_by_ft = { <filetype> = { "<nvim-lint linter>" } },
    formatters_by_ft = { <filetype> = { "<conform formatter>" } },
    formatters = { <conform formatter> = { <conform.FormatterConfig overrides> } },
  }
end

return M
```

`lua/lang/init.lua` merges every module listed in its local `specs()` function; list-valued
entries are concatenated, map-valued entries are deep-merged. Consumers:

- `lua/plugins/nvim_lspconfig.lua` -> `vim.lsp.config(name, cfg)` + `vim.lsp.enable(...)`
- `lua/plugins/nvim_lint.lua` -> `lint.linters_by_ft`, triggered on `BufEnter`,
  `BufWritePost`, `InsertLeave`, plus `<leader>ll`
- `lua/plugins/conform.lua` -> `format_on_save` gated by `vim.g.autoformat_enabled`,
  `timeout_ms = 500`, `lsp_format = "fallback"`, manual format on `<leader>fo`

**Every new language module added for this work must follow that contract and be
registered in `lua/lang/init.lua`.** No ad-hoc `vim.lsp.start` calls, no per-plugin
formatter setup.

Also relevant: `vim.lsp.config("*", { root_markers = { ".git" } })` is set globally, and
`vim.g.autoformat_enabled = true` in `lua/core/globals.lua`.

---

## 2. Workload profile (what the code actually looks like)

Three sibling repositories under one parent code folder. Descriptions are generic; the
technical facts (versions, tools) are accurate and are what the tooling must satisfy.

### Workspace A — Nx-managed npm + .NET monorepo

- Four packages under `packages/`:
  1. a web-component library (hundreds of self-contained component folders),
  2. a TypeScript API-client library,
  3. a TypeScript device-communication library,
  4. a .NET class library with test projects (its own `.sln`).
- ~4300 `.ts`, ~380 `.cs`, ~260 `.html`, ~260 `.json`, ~475 `.md`, ~70 `.yaml`, 3 `.ps1`.
- Build orchestration: Nx (`nx run-many -t build|test|lint`) with an inter-package
  dependency order. The .NET solution is built through an Nx dotnet plugin.
- TypeScript is compiled through a **compiler-transform wrapper** (`ts-patch`, binary
  `tspc`), configured via `compilerOptions.plugins` entries of the shape
  `{ "transform": "<name>" }`.
- Root `tsconfig.json` uses **project references** to all packages.

### Workspace B — Electron + mobile TypeScript application

- ~245 `.ts`, plus Electron main/preload, gulp/esbuild/rollup build scripts (`.mjs`),
  PowerShell packaging scripts (`.ps1`), a few `.html`/`.css`.
- Uses **TSLint 5** (`tslint.json`, `tslint:recommended`) — **no ESLint config at all**.
- Same `ts-patch` transform setup as Workspace A.

### Workspace C — Web-component library

- ~420 `.ts`, ~150 `.html`, ~140 `.json`, ~85 `.md`.
- ESLint 8 with a legacy `.eslintrc`.
- Same `ts-patch` transform setup.

### Cross-cutting technical facts (these drive every decision below)

| Fact | Consequence for Neovim |
| --- | --- |
| ESLint **8.x** with **legacy `.eslintrc`** files (not flat config) in 4 packages | ESLint integration must be forced into eslintrc mode if a 9.x binary is ever used |
| One package still pins **ESLint 6.8** + an older shared config | The modern ESLint language server may refuse it; needs a documented fallback |
| Shared ESLint config resolved from `node_modules`, incl. a Sonar-derived rule plugin | Linting only works with the repo's `node_modules` installed |
| ESLint invoked as `eslint . --ext .ts` per package; several `sonar*` rules explicitly disabled per repo | Editor diagnostics must come from the repo's own config, not a global rule set |
| **Prettier 3** everywhere; config is referenced by a `"prettier": "<shared-config-pkg>"` field in `package.json` in 4 of 5 packages, one package has `.prettierrc.json` | Formatter must resolve config **and** the prettier binary from the project |
| `.prettierignore` at every repo root; CI runs `prettier --check .` | Format-on-save must respect ignore files and must not fight CI |
| TypeScript **5.0.4** in most packages, **4.9.5** in one | A single TS language server process picks one SDK; mixed versions are a known hazard |
| Web components use both Polymer-style templates (`[[prop]]` bindings) and Lit; `lit` 3.x is a dependency | Lit template checking is desirable, but several template rules must be disabled or Polymer syntax produces false positives |
| Tests: `@web/test-runner`, Karma, and Mocha, all running **compiled JS** | Test runners are terminal work, not editor work; out of scope here |
| C# projects target **netstandard2.1** and **net8.0**; a Sonar C# analyzer is a `PackageReference` | Roslyn already surfaces those analyzer diagnostics; no separate C# linter needed |
| C# subtree has its own `.editorconfig`: `indent_style = tab`, `indent_size = 4`, plus ~100 `csharp_style_*` rules | Indentation must come from EditorConfig, not from global Neovim options |
| Parent code folder has a root `.editorconfig`: 2-space, UTF-8, final newline, trim trailing whitespace, relaxed for `.md` | Same |
| Git hooks (commitlint / staged-file linting) are installed **per package** | Committing from Neovim will trigger them; expect hook output, not an editor concern |

---

## 3. Target tooling matrix

| Filetype | LSP | Diagnostics source | Formatter |
| --- | --- | --- | --- |
| `typescript`, `javascript` | `vtsls` (+ `ts-lit-plugin` tsserver plugin) | `eslint` LSP where an ESLint config exists; custom `tslint` nvim-lint linter in the TSLint repo | `prettier` (project-resolved) |
| `html` | `html` (vscode-html-language-server) | LSP only | `prettier` if project has prettier config, else LSP |
| `css` | `cssls` | LSP only | `prettier` if project has prettier config, else LSP |
| `json`, `jsonc` | `jsonls` (already configured) | LSP schema validation | `prettier` if project has prettier config, else existing `jq` |
| `yaml` | `yamlls` (already configured) | LSP schema validation | `prettier` if project has prettier config, else existing `yamlfmt` |
| `markdown` | `marksman` (already configured) | none | `prettier` if project has prettier config, else none |
| `cs` | `roslyn_ls` via `roslyn.nvim` | Roslyn + project-referenced analyzers | LSP formatting only (honours the C# `.editorconfig`) |
| `ps1` | `powershell_es` | PSScriptAnalyzer via the LSP | LSP formatting only |
| `xml` (`.csproj`, `.sln` adjacent) | optional `lemminx` | optional | optional |

Deliberate non-goals: no Biome, no Oxlint, no `eslint_d` as primary, no `csharpier`, no
second TypeScript server, no Sonar rules that the repositories have switched off.

---

## 4. External programs to install

Installation strategy (global npm vs. per-project vs. a version manager vs. Mason) is an
**open question** — see section 11. The list of *what* is needed is settled:

| Program | Provides | Notes |
| --- | --- | --- |
| Node.js + npm | Everything JS/TS | Must be the Node version the repos build with |
| `@vtsls/language-server` | `vtsls` | Uses the project's own TypeScript when it can find it |
| `vscode-langservers-extracted` | `vscode-eslint-language-server`, `vscode-html-language-server`, `vscode-css-language-server`, `vscode-json-language-server` | One package covers 4 servers, incl. the already-used `jsonls` |
| `ts-lit-plugin` | Lit/`html` tagged-template diagnostics inside the TS language service | Needs an absolute install path for the `vtsls` global-plugin entry |
| `prettier` | Formatting | **Do not install globally as the primary.** conform's `prettier` builtin already resolves `node_modules/.bin/prettier` upward. A global copy is only a fallback for files outside any project |
| `tslint` (v5) | Diagnostics for Workspace B | Provided by that repo's `node_modules`; must be invoked from there, not globally |
| .NET SDK | `dotnet`, MSBuild, analyzers | Needs an SDK able to build `net8.0` and `netstandard2.1` targets |
| Roslyn language server | `roslyn_ls` | Distributed as a dotnet tool or a NuGet payload; `roslyn.nvim` can also manage discovery |
| `pwsh` (PowerShell 7) | Host process for the PowerShell LSP | Optional; only needed if `.ps1` files are edited |
| PowerShellEditorServices bundle | `powershell_es` | Optional; `bundle_path` must point at the extracted release |
| JDK 17+ | SonarLint language server | Optional, only for section 9 |
| `marksman`, `jq`, `yamlfmt` | Already in use | Keep; they become fallbacks behind `prettier` |

Treesitter parsers to ensure: `typescript`, `javascript`, `html`, `css`, `json`, `jsonc`,
`yaml`, `markdown`, `markdown_inline`, `c_sharp`, `xml`, `bash`. Verify whether a
`powershell` parser is available in the pinned nvim-treesitter revision; if not, `.ps1`
gets LSP support without treesitter highlighting, which is acceptable.

Neovim plugins to add via `vim.pack`: `roslyn.nvim` (C#), and optionally `sonarlint.nvim`.
Everything else is covered by the already-installed `nvim-lspconfig`, `conform.nvim` and
`nvim-lint`.

---

## 5. TypeScript / JavaScript

### 5.1 Language server: `vtsls`

Chosen over `ts_ls` because these repos depend on **TypeScript language-service plugins**
(Lit template checking) and on VS Code-equivalent refactorings. Do **not** enable `ts_ls`
and `vtsls` simultaneously.

Requirements:

1. **Project-local TypeScript.** The server must use the repository's TypeScript
   (5.0.4 / 4.9.5), not a newer bundled one. `vtsls` resolves the workspace TypeScript
   automatically, **but only once per server process**. Because one workspace here
   contains two different TypeScript versions, the installer must document the symptom
   (odd diagnostics in the package with the older TypeScript) and the workaround
   (open that package as its own Neovim session / cwd).
2. **Monorepo root.** The upstream `vtsls` config already roots at the nearest package
   manager lockfile and falls back to `.git`. That yields the monorepo root, which is
   correct: it finds each package's `tsconfig.json` from there. Do not override
   `root_dir` with the global `.git`-only marker.
3. **Project references.** The root `tsconfig.json` uses `references`. Cross-package
   "go to definition" may land in generated `.d.ts`/`dist` output instead of source if the
   packages have not been built. Verification step: build the workspace once, then confirm
   navigation targets.
4. **Build transforms are not applied in the editor.** The repos compile via a
   `ts-patch` wrapper with `{ "transform": ... }` entries in `compilerOptions.plugins`.
   Stock `tsserver` ignores entries without a `name` field, so those transforms do **not**
   run in the editor. Verification step: confirm no source relies on transform output at
   *type* level. If it does, expect false "missing member" errors in the editor only.
5. Memory: the largest workspace is big (4000+ TS files). Raising the tsserver memory
   limit is expected to be necessary.

### 5.2 Lit / web-component template checking

`ts-lit-plugin` is the equivalent of the VS Code `lit-plugin` extension: it is a
**TypeScript language-service plugin**, so it must be loaded into the TS server, not run
as a separate LSP.

Two ways to load it, and the choice matters:

- **Repo-local**: add `{ "name": "ts-lit-plugin", "rules": { ... } }` to the repository's
  `tsconfig.json` `plugins` array. Keeps rules with the code, but modifies work repos.
- **Global (preferred here)**: register it through the `vtsls` setting
  `vtsls.tsserver.globalPlugins`, with an entry containing at least `name`, an absolute
  `location`, `languages`, and `enableForWorkspaceTypeScriptVersions = true` so it also
  loads when the workspace TypeScript is used.

**Rules that must be disabled**, because the codebase mixes Polymer template syntax
(`[[prop]]`, `{{prop}}`) with Lit and would otherwise produce constant false positives:

```
no-complex-attribute-binding   -> off
no-boolean-in-attribute-binding-> off
no-incompatible-property-type  -> warning
no-incompatible-type-binding   -> off
```

**Open verification item for the installer:** confirm how per-rule configuration is passed
to a global tsserver plugin under `vtsls` (`configNamespace` + a settings block versus
repo-local `tsconfig.json`). If global rule configuration cannot be made to work, fall back
to repo-local `tsconfig.json` plugin entries, or leave the plugin disabled — it is a
convenience, not a requirement. Do not ship a setup that floods the buffer with template
errors.

Optional extra: `custom-elements-languageserver` adds completion for custom elements used
in standalone `.html` files. Treat as opt-in; skip it if it duplicates `vtsls` diagnostics.

### 5.3 ESLint

Use the **ESLint language server** (`vscode-eslint-language-server`, `eslint` in
lspconfig) rather than the `nvim-lint` `eslint` linter. Reasons specific to these repos:

- It resolves the ESLint binary and the shared config from each package's own
  `node_modules`, and it handles monorepos with one server process.
- It only attaches when an ESLint config is actually found upward from the file, so the
  TSLint-only repo is left alone automatically.
- It exposes fix-all as a command, which matches the chosen "fixes on demand" policy.

Required settings:

| Setting | Value | Why |
| --- | --- | --- |
| `settings.format` | `false` | Prettier owns formatting; upstream default is `true` |
| `settings.codeActionOnSave.enable` | `false` (upstream default) | Decision: ESLint fixes are manual |
| `settings.experimental.useFlatConfig` | `false` | All configs are legacy `.eslintrc`; protects against a 9.x binary defaulting to flat config |
| `settings.workingDirectory` | `{ mode = "auto" }` (upstream default) | Correct per-package resolution in the monorepo |
| `settings.run` | `"onType"` or `"onSave"` | `onType` is the default; switch to `onSave` if the largest repo feels slow |

Keymap requirement: a normal-mode mapping that runs the buffer-local `LspEslintFixAll`
command created by the server's `on_attach` (suggested `<leader>lf`, must not collide with
existing `<leader>fo` / `<leader>ll` / `<leader>li`).

**Known risk — ESLint 6.8 package.** Current versions of the ESLint language server may
refuse to run against ESLint 6. If the server reports a version/library error for that one
package, the documented fallback is: keep the LSP for the other packages and lint that
package from the terminal with its own `npm run lint`. Do **not** add a global ESLint
binary — it would silently lint with the wrong rule set.

**Do not** enable both the ESLint LSP and an `nvim-lint` ESLint linter for the same
filetype; that produces duplicate diagnostics.

### 5.4 TSLint (the one repo without ESLint)

TSLint 5 is deprecated and has no maintained Neovim integration, so define a **custom
`nvim-lint` linter**. Requirements:

- Command: the repo-local `node_modules/.bin/tslint`, discovered by walking upward from
  the buffer; never a global install. If not found, the linter must silently do nothing.
- Arguments: JSON output plus the project's `tsconfig.json`, then the file path. TSLint's
  JSON records expose `name`, `startPosition` / `endPosition` (0-based `line` and
  `character`), `failure`, `ruleName`, and `ruleSeverity`.
- Parser: decode the JSON array into `vim.Diagnostic` entries; map `ERROR` to
  `vim.diagnostic.severity.ERROR`, `WARNING` to `WARN`; set `source = "tslint"` and
  `code = ruleName`.
- The linter must be registered exactly like the existing custom `zsh` linter in
  `lua/plugins/nvim_lint.lua` (patch `lint.linters.tslint`), with the ft mapping coming
  from the language module.
- **Performance guard:** running TSLint with a project creates a full TypeScript program,
  which is slow on a 245-file repo. The existing autocmd triggers on `BufEnter`,
  `BufWritePost` *and* `InsertLeave`. TSLint must be restricted to `BufWritePost` and the
  manual `<leader>ll` mapping. Implement this as a general capability (a set of linters
  that only run on write) rather than a hard-coded special case.

### 5.5 Formatting

`conform.nvim`'s `prettier` builtin already does the right thing for these repos:

- its command resolves `node_modules/.bin/prettier` by walking up from the file;
- its `cwd` detection understands both `.prettierrc*` files **and** a `"prettier"` key in
  `package.json`, which is how 4 of the 5 packages declare their shared config;
- running with `--stdin-filepath` from that cwd means `.prettierignore` is honoured.

Required override: set `require_cwd = true` on the `prettier` formatter so it **refuses to
run** outside a project that actually has a Prettier config. This prevents Prettier from
reformatting unrelated files with default settings.

---

## 6. HTML, CSS, JSON, YAML, Markdown

- Add `html` and `cssls` (from `vscode-langservers-extracted`, same package that provides
  the ESLint and JSON servers). `.html` files here are demo/doc pages; component templates
  live inside TypeScript tagged templates and are handled by `vtsls` + `ts-lit-plugin`.
- The existing `lua/lang/data.lua` maps `json -> jq` and `yaml -> yamlfmt`, and
  `lua/lang/markdown.lua` has no formatter. Inside these repos, **Prettier is authoritative
  for JSON, YAML, Markdown and HTML** (CI runs `prettier --check .` over the whole repo).
- Required change: make Prettier the first choice with the existing tools as fallback,
  using conform's `stop_after_first` together with `require_cwd = true` on `prettier`:

  ```lua
  formatters_by_ft = {
    json = { "prettier", "jq", stop_after_first = true },
    yaml = { "prettier", "yamlfmt", stop_after_first = true },
    markdown = { "prettier", stop_after_first = true },
    html = { "prettier", stop_after_first = true },
    css = { "prettier", stop_after_first = true },
  },
  formatters = { prettier = { require_cwd = true } },
  ```

  Because `lua/lang/init.lua` **concatenates** list values across modules, the new entries
  must either replace the ones in `data.lua` or be ordered so `prettier` comes first —
  verify the merged result with `:lua vim.print(require("lang").formatters_by_ft())` after
  the change. This is a real merge hazard, not a theoretical one.
- Keep `format = { enable = false }` on `yamlls` (already set) so the LSP does not compete.
- Set `provideFormatter`/`format` off for the HTML server if it starts competing with
  Prettier on files inside a project.

---

## 7. C#

### 7.1 Language server

`roslyn.nvim` driving the Roslyn language server, per the decision already recorded in
`LANGUAGE-TOOLING.md`. Requirements:

- Install the independently distributed, MIT-licensed Roslyn language-server package
  (dotnet tool or NuGet payload). Do not extract the separately licensed VS Code C#
  extension runtime.
- A .NET SDK new enough to run the server must be present **in addition to** an SDK that
  can build the projects' `net8.0` / `netstandard2.1` targets.
- **Solution discovery:** the `.sln` sits several directories below the git root, inside
  an npm monorepo, and there are multiple `.csproj` files. The global
  `vim.lsp.config("*", { root_markers = { ".git" } })` must not force the server to the
  git root; `roslyn.nvim` performs its own solution/project detection and must be allowed
  to. Verification step: open a `.cs` file and confirm the server reports the intended
  solution, and that cross-project navigation into the referenced projects works.
- Analyzers: the projects already reference analyzer NuGet packages, so quality
  diagnostics arrive through Roslyn. **Do not add a separate C# linter.**

### 7.2 Formatting

No external C# formatter. `conform` is already configured with `lsp_format = "fallback"`,
so with no `formatters_by_ft.cs` entry the Roslyn server formats the buffer and honours the
subtree `.editorconfig` (tabs, width 4, ~100 style rules). Adding an opinionated external
formatter would fight both the `.editorconfig` and CI.

Optional convenience: a user command wrapping `dotnet format` for whole-project cleanup,
explicitly not bound to save.

---

## 8. PowerShell

Only a handful of packaging scripts, so this is low priority and optional.

- `powershell_es` (PowerShell Editor Services) provides completion, diagnostics via
  PSScriptAnalyzer, and formatting in one server.
- It requires `pwsh` on `PATH` and a `bundle_path` pointing at an extracted
  PowerShellEditorServices release. On a Linux/WSL machine where these Windows-oriented
  scripts are only read, it is acceptable to skip installation entirely and rely on
  treesitter highlighting.
- If enabled: no separate linter (PSScriptAnalyzer is inside the server), and formatting
  through `lsp_format` fallback, i.e. no `formatters_by_ft.ps1` entry.

---

## 9. SonarLint (optional, connected mode)

Requested as an optional section. Understand precisely what it does and does not add here:

- **Already covered without it:** the shared ESLint config used by the TS/JS packages
  includes a Sonar-derived ESLint plugin, so Sonar's JS/TS code-smell rules already appear
  as ESLint diagnostics. The C# projects reference a Sonar analyzer NuGet package, so
  Sonar's C# rules already appear through Roslyn.
- **What it adds:** the full rule set including security-focused rules, and — via
  **connected mode** — the server-side quality profile, rule activation and issue
  suppressions, so local diagnostics match what the server enforces.
- **Why connected mode matters here specifically:** several repos deliberately switch off
  a number of `sonar*` ESLint rules. A standalone, unconnected SonarLint ignores those
  local overrides and will report issues that nothing in CI enforces. Connected mode is
  the only configuration that stays truthful.

Requirements if installed:

1. A **JDK 17 or newer**, installed separately and pointed at explicitly — do not assume
   the system default Java is suitable or even present.
2. `sonarlint.nvim` plus the `sonarlint-language-server` payload; filetypes limited to
   what is actually wanted (`typescript`, `javascript`, `cs`).
3. Connected-mode configuration requires: the analysis server's base URL, an
   authentication token generated from that server's user account, and the **project key**
   for each repository. The project key is already present in each repo's Sonar properties
   file — read it from there rather than guessing.
4. The token is a secret: it must be stored outside the version-controlled Neovim config
   (environment variable or a file read at startup, referenced but never committed).
5. Duplicate-diagnostic control: if SonarLint is enabled for `typescript`, the same issue
   may be reported by both ESLint and SonarLint. Decide one of — disable SonarLint for
   `typescript` and keep it for `cs` only, or accept duplicates, or filter by source in a
   diagnostic handler. This must be an explicit decision, not an accident.
6. Sanity check: SonarLint must not be allowed to send source code anywhere other than the
   configured internal analysis server. Connected mode binds to that server only; do not
   configure any cloud/SaaS endpoint.

Recommendation: install this **last**, after everything in sections 5–8 is verified
working, and behind a flag that is easy to turn off.

---

## 10. Cross-cutting policies

### Formatting policy (decided)

- Format on save with Prettier, for files inside a project that has a Prettier config.
- ESLint fixes are **never** applied on save; only via an explicit mapping.
- The existing `vim.g.autoformat_enabled` toggle and `<leader>fo` manual format stay as-is.
- `timeout_ms = 500` is the current format-on-save budget. Prettier spawned from
  `node_modules` on a large monorepo may exceed it. If saves start silently skipping
  formatting, raise the timeout rather than switching tools; `prettierd` is a possible
  optimisation but adds a daemon and must not become the reason CI and editor disagree.

### EditorConfig

- Neovim's built-in EditorConfig support handles this; nothing to install.
- The parent code folder holds a root `.editorconfig` (2-space, UTF-8, final newline, trim
  trailing whitespace, relaxed rules for Markdown), and the C# subtree has its own
  `root = true` file using **tabs, width 4**. Nearest-root-wins is exactly the required
  behaviour — do not override indentation globally per filetype in Lua, or the C# subtree
  will be formatted wrongly.
- `mini.trailspace` is already installed; combined with `trim_trailing_whitespace = true`
  this is consistent, but confirm it does not strip whitespace in Markdown, where the root
  config explicitly disables trimming.

### Diagnostics hygiene

- One server per language per buffer: `vtsls` **or** `ts_ls`, never both.
- One lint source per file: ESLint LSP where an ESLint config exists, the custom TSLint
  linter only in the repo that has `tslint.json`, never both, never plus a global linter.
- Everything must degrade to silence when a repo's `node_modules` is absent, rather than
  erroring on every keystroke.

### What stays out of scope

Test runners (browser-based and Karma/Mocha suites), the schema-generation step some
packages need before tests, Nx task orchestration, package-registry authentication, and
per-package git hooks. These are terminal workflows. A DAP setup for Node/Electron/.NET is
a possible follow-up but is not part of this tooling requirement.

---
## 11. User input

1. Consider an .env file in the nvim/ folder that owns the possible keys, set the copilot plugin to true etc. If something should load or similar. 
2. Lualine integration should work for all new plugins.
3. I want a nice markdown viewer as well, if not installed now we can defer to later.

---
## 12. Open questions

1. **Tool installation and resolution strategy — explicitly deferred.** Options:
   (a) global npm installs on `PATH`; (b) strictly project-local with wrappers that resolve
   `node_modules/.bin`; (c) reintroduce Mason for server binaries only; (d) OS/Nix package
   manager. Constraint to respect whichever is chosen: **ESLint, TSLint, TypeScript and
   Prettier must resolve from the repository**, because the repos pin ESLint 8 with legacy
   config, ESLint 6 in one package, TypeScript 5.0.4/4.9.5, and Prettier 3 with a shared
   config package. Only the language-server executables (`vtsls`,
   `vscode-*-language-server`, Roslyn, PowerShell Editor Services) are candidates for
   global installation.
2. Should `ts-lit-plugin` be enabled globally for **all** TypeScript projects, or only
   inside these three workspaces? Global is simpler; project-scoped avoids surprising
   template diagnostics in unrelated personal projects.
3. Is `<leader>lf` free for "ESLint fix all"? The installer must check the existing
   which-key/leader mappings before binding.
4. Should the workspace with mixed TypeScript versions be handled by opening it as two
   separate Neovim sessions, or by accepting one shared server?
5. Are `.ps1` files ever actually edited on this machine, or only read? Determines whether
   section 8 is installed at all.
6. Is an XML language server wanted for `.csproj`/pipeline files, or is treesitter enough?

---

## 12. Acceptance checklist

Work through this after installation; each item is a concrete observable.

- [ ] Opening a `.ts` file in the web-component library attaches exactly one TypeScript
      server, and `:lua vim.print(vim.lsp.get_clients({ bufnr = 0 }))` confirms it.
- [ ] Hover, go-to-definition and rename work across package boundaries in the monorepo.
- [ ] The TypeScript version in use matches the repository's pin, not a newer bundled one.
- [ ] ESLint diagnostics appear in the ESLint-configured packages, and match
      `npm run lint` output for the same file (no extra rules, no missing rules).
- [ ] No ESLint diagnostics appear in the TSLint-only repo; TSLint diagnostics appear
      there instead, on save only.
- [ ] Saving a `.ts`, `.json`, `.yaml`, `.md` or `.html` file inside a repo produces the
      same bytes as `prettier --write` on that file, and files listed in `.prettierignore`
      are left untouched.
- [ ] Saving a file **outside** any project does not run Prettier.
- [ ] Lit/Polymer templates produce no false-positive diagnostics from the four disabled
      rules.
- [ ] Opening a `.cs` file loads the intended solution; analyzer diagnostics appear;
      formatting produces tab indentation per the subtree `.editorconfig`.
- [ ] `:lua vim.print(require("lang").formatters_by_ft())` and `linters_by_ft()` show the
      intended merged result with no duplicated or mis-ordered entries.
- [ ] With a repo's `node_modules` deleted, nothing errors on every keystroke; tooling
      degrades quietly.
