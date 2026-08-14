# AI Tools

- `$HOME/.config/ai` owns model-agnostic commands, skills, context, and workflows.
- Client-specific behavior stays under its client directory, such as `$HOME/.config/opencode` or `$HOME/.config/claude`.
- Shared command and skill entries exposed through client directories may be symlinks; edit the shared source rather than a client projection.
- Specialized workflows own their contracts and operating policy. Do not copy that policy into generic dotfiles context or load it for unrelated dotfiles tasks.

Read the relevant client configuration and shared source before changing discovery, permissions, commands, skills, agents, or plugins.
