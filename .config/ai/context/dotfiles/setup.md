# Setup

`$HOME/.dotfiles_setup/bootstrap.sh` is the sole supported setup entrypoint.

- Bootstrap acquires or updates the bare repository, previews and applies a sparse profile from `profiles/*.paths`, then separately offers the matching optional software manifest.
- After applying configuration, bootstrap idempotently creates or updates untracked root shell startup shims and records their exclusions in the bare repository's local `info/exclude` file.
- `bootstrap.sh --repair-shell` restores those private startup shims without fetching, changing profiles, or installing software.
- Declining the install prompt must leave setup configuration-only; software tasks are owned by `internal/install_programs.sh` and `profiles/*.programs` manifests.
- `bootstrap.sh --debug` requires a local checkout and validates all profiles/scripts before simulating the complete workstation installer without persistent changes or network activity.
- Interactive prompts must use the controlling terminal when bootstrap is executed from standard input and must fail on unavailable input rather than retrying on EOF.
- Preserve safe reruns, no-op detection, dry-run behavior, and task isolation.
- Prefer user-local or upstream-release ownership for application-specific tools when the existing setup module follows that model.
- Keep intentionally manual system or toolchain prerequisites manual unless the user explicitly changes their ownership.

Read the relevant setup scripts for current packages, versions, flags, output, and supported distributions instead of recording those mutable details here.
