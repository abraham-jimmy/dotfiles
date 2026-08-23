# TypeScript, JavaScript, C#, and Lit Tooling Notes

Research snapshot: 2026-08-23

These notes are exploratory. The workplace repository's existing configuration, tool versions, and CI requirements should take priority over global editor preferences.

## Tool Roles

| Tool | Purpose |
| --- | --- |
| LSP | Completion, navigation, hover, refactoring, and editor diagnostics |
| Type checker | Verifies types during development and builds |
| Linter or analyzer | Finds suspicious code, style problems, and possible bugs |
| Formatter | Rewrites code into a consistent layout |

One program may cover several roles, but they remain separate concerns.

## TypeScript and JavaScript

### Language Servers

#### Native TypeScript LSP

Microsoft's native TypeScript implementation, historically called `tsgo`, is the strategic future of TypeScript. Current TypeScript 7 releases expose the native language server through `tsc --lsp`. It is substantially faster and uses less memory than JavaScript-based `tsserver`.

Use it when:

- The project uses TypeScript 7.
- Performance in a large monorepo matters.
- Required framework and TypeScript language-service plugins are supported.

Validate refactoring, framework, and plugin compatibility before making it the workplace default.

Sources:

- [TypeScript native port](https://github.com/microsoft/typescript-go)
- [Microsoft native port announcement](https://devblogs.microsoft.com/typescript/typescript-native-port/)

#### vtsls

`vtsls` packages the TypeScript support from VS Code as an LSP server. It generally offers the closest non-VS-Code editor experience to VS Code's TypeScript extension.

Use it when:

- The project uses TypeScript 6 or older.
- The team expects VS Code-like TypeScript behavior.
- The project uses TypeScript language-service plugins.
- Framework compatibility and refactoring depth matter more than maximum speed.

Configure it to use the project's local TypeScript installation rather than only its bundled version.

Source: [vtsls](https://github.com/yioneko/vtsls)

#### typescript-language-server

`typescript-language-server` is the established LSP wrapper around `tsserver`. It is mature and conservative but does not expose as much VS Code-specific behavior as `vtsls`.

Source: [typescript-language-server](https://github.com/typescript-language-server/typescript-language-server)

### LSP Recommendation

- For TypeScript 7, evaluate the native `tsc --lsp` server.
- For TypeScript 6, Lit, or plugin-heavy projects, start with `vtsls`.
- Keep `typescript-language-server` as the conservative fallback.
- Do not run multiple TypeScript language servers on the same buffer.
- Prefer the project's local TypeScript SDK and configuration.

### Linters

#### ESLint and typescript-eslint

ESLint with `typescript-eslint` remains the safest workplace default.

Strengths:

- Largest framework and plugin ecosystem.
- Compiler-backed type-aware rules.
- Strong React, Lit, testing, and import support.
- Usually already integrated into workplace CI.

Tradeoffs:

- Slower than Rust-based alternatives.
- Type-aware linting can be expensive.

Sources:

- [ESLint](https://eslint.org/)
- [typescript-eslint typed linting](https://typescript-eslint.io/getting-started/typed-linting/)

#### Oxlint

Oxlint is a modern, performance-focused Rust linter with broad built-in TypeScript, React, import, testing, and framework rules.

Strengths:

- Extremely fast.
- Broad built-in rule coverage.
- Growing typed-linting support.

Tradeoffs:

- Custom JavaScript plugin support is less mature than ESLint.
- It cannot yet replace every company-specific ESLint plugin.
- Framework template support varies.

Source: [Oxlint](https://oxc.rs/docs/guide/usage/linter.html)

#### Biome

Biome combines formatting, linting, import organization, and an LSP in one Rust-based toolchain.

Strengths:

- Fast and simple integrated tooling.
- Can replace Prettier and part of ESLint.
- Attractive for greenfield projects.

Tradeoffs:

- Does not implement the complete ESLint plugin ecosystem.
- Type-aware analysis is not identical to TypeScript compiler analysis.
- Some framework support remains less mature.

Source: [Biome](https://biomejs.dev/)

### Linter Recommendation

Honor the repository's existing tool:

- Use ESLint when an ESLint configuration exists.
- Use Biome when a Biome configuration exists.
- Use Oxlint when an Oxlint configuration exists.
- Avoid starting multiple linters that publish duplicate diagnostics.

For a new project, evaluate Oxlint for speed while retaining ESLint for unsupported custom or framework rules.

## C#

### Language Servers

#### Roslyn Language Server

Microsoft's Roslyn Language Server is the modern first-party C# language engine. It understands C# syntax, types, solutions, projects, source generators, refactorings, and Roslyn analyzer diagnostics.

For Neovim, [`roslyn.nvim`](https://github.com/seblyng/roslyn.nvim) is the most capable integration when multiple solutions, generated-source navigation, target selection, Razor, or Blazor are involved. Native `nvim-lspconfig` also provides `roslyn_ls` for simpler projects.

Use the independently distributed, MIT-licensed Roslyn language-server package rather than extracting the separately licensed VS Code C# extension runtime.

Sources:

- [Roslyn](https://github.com/dotnet/roslyn)
- [Roslyn language-server package](https://www.nuget.org/packages/roslyn-language-server)

#### csharp-ls

`csharp-ls` is an independent, MIT-licensed Roslyn-based language server with good standard-LSP compatibility. It is a sensible fallback if the Microsoft server or its Roslyn-specific Neovim integration causes problems.

Source: [csharp-language-server](https://github.com/razzmatazz/csharp-language-server)

#### OmniSharp

OmniSharp is primarily a legacy fallback for older .NET Framework, Mono, and older Unity projects. It should not be the first choice for a new SDK-style .NET project.

Source: [OmniSharp Roslyn](https://github.com/OmniSharp/omnisharp-roslyn)

### C# Analyzers and Formatting

C# normally uses project-referenced Roslyn analyzers instead of a separate editor-only linter:

```text
.csproj and analyzer packages
        -> Roslyn compiler and language server
        -> editor and build diagnostics
        -> CI enforcement through dotnet build
```

Recommended components:

- Built-in .NET analyzers provide `CAxxxx` quality, security, and performance rules.
- Repository `.editorconfig` files control rule severity and code style.
- Roslynator can add a broad set of additional analyzers.
- SonarAnalyzer is relevant when the organization uses SonarQube or SonarCloud.
- StyleCop is common in older strict-style repositories but is less attractive for greenfield projects.
- `dotnet format` applies formatting and fixable analyzer changes, but `dotnet build` remains the authoritative analyzer gate.

Sources:

- [.NET code analysis](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/overview)
- [`dotnet format`](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format)
- [Roslynator](https://github.com/dotnet/roslynator)

### C# Recommendation

- Prefer Roslyn Language Server with `roslyn.nvim` for modern SDK-style projects.
- Use `csharp-ls` as the independent fallback.
- Reserve OmniSharp for legacy projects that require it.
- Let the repository own analyzers, `.editorconfig`, SDK versions, and CI severity.
- Use `dotnet build` as the authoritative diagnostics check.

## Lit

In a TypeScript or JavaScript workplace, "Lit" most likely means the Lit web-component library rather than a linter or language server.

Source: [Lit documentation](https://lit.dev/docs/)

A basic Lit component looks like:

```typescript
import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

@customElement("user-card")
class UserCard extends LitElement {
  @property() name = "";

  render() {
    return html`<p>Hello ${this.name}</p>`;
  }
}
```

Important concepts:

- Components are standard browser custom elements.
- `LitElement` extends `HTMLElement`.
- Templates use tagged template literals such as `` html`...` ``.
- Properties are reactive.
- Styles commonly use Shadow DOM.
- Lit components can be consumed from plain HTML or other frameworks.

Ordinary TypeScript understands the surrounding class but does not completely understand the HTML embedded inside Lit templates. Lit-specific tooling fills that gap:

- `ts-lit-plugin` adds template diagnostics and completion to the TypeScript language service.
- `lit-analyzer` provides CLI analysis.
- `eslint-plugin-lit` supplies Lit-specific lint rules.

Sources:

- [Lit development tools](https://lit.dev/docs/tools/development/)
- [lit-analyzer and ts-lit-plugin](https://github.com/runem/lit-analyzer)
- [eslint-plugin-lit](https://github.com/43081j/eslint-plugin-lit)

If a project depends on `ts-lit-plugin`, `vtsls` or `typescript-language-server` may initially be safer than the native TypeScript LSP because they use the established TypeScript plugin system.

### Questions for the Team

1. By Lit, do you mean the npm `lit` package and `LitElement`?
2. Are we authoring Lit components or only consuming a web-component library?
3. Which TypeScript and Lit versions does the repository use?
4. Do we use `lit-analyzer`, `ts-lit-plugin`, or `eslint-plugin-lit`?
5. Are Lit template checks enforced in CI or only in the editor?
6. Which tool configurations in the repository are authoritative?
