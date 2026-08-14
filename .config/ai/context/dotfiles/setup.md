# Setup

`$HOME/.dotfiles_setup` is the source of truth for fresh-machine bootstrap and provisioning behavior.

- `bootstrap.sh` handles initial repository acquisition and invokes `setup.sh`.
- `setup.sh` discovers and runs setup functions from `modules/*.sh`.
- Preserve safe reruns, no-op detection, dry-run behavior, and task isolation.
- Prefer user-local or upstream-release ownership for application-specific tools when the existing setup module follows that model.
- Keep intentionally manual system or toolchain prerequisites manual unless the user explicitly changes their ownership.

Read the relevant setup scripts for current packages, versions, flags, output, and supported distributions instead of recording those mutable details here.
