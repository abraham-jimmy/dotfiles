# Python LSP venv Auto-Detection Issue

I have a Neovim setup using `basedpyright` for Python. In my repo, the Python virtual environment is at the repo root:

- `.venv/bin/python`

But when I open this file:

- `scripts/crawl_sharepoint/crawl.py`

the LSP chooses this as the workspace root:

- `~/Documents/repos/Acorn-LocalAI-Agent/scripts/crawl_sharepoint`

instead of the repo root:

- `~/Documents/repos/Acorn-LocalAI-Agent`

This likely happens because there is a nested file here:

- `scripts/crawl_sharepoint/requirements.txt`

As a result, `basedpyright` does not discover the repo-root `.venv`, and I get import warnings such as:

- `Import "dotenv" could not be resolved`

even though `python-dotenv` is installed correctly inside:

- `~/Documents/repos/Acorn-LocalAI-Agent/.venv`

Confirmed facts:

- `python-dotenv` is installed in the repo venv
- Neovim currently sees `/usr/bin/python3` instead of the repo venv interpreter
- `basedpyright` is active and attached
- `:LspInfo` shows the root directory as `scripts/crawl_sharepoint`

What I want fixed:

- Python projects in Neovim should automatically use the repo-local `.venv` when it exists
- This should work without manually running `source .venv/bin/activate` before starting Neovim
- The setup should prefer the modern explicit command name `python3` for shell and system checks where relevant
- For actual project execution and LSP analysis, the interpreter should be the repo-local `.venv/bin/python`
- If no `.venv` is found for a Python project, I want a clear warning inside Neovim so I know to create or set up the virtualenv

Desired behavior:

- Open any Python file in the repo
- Neovim and `basedpyright` should detect the repo root, not the nested subfolder root
- It should automatically use `./.venv/bin/python` from the repo root
- Imports like `from dotenv import load_dotenv` should resolve without warnings
- If `.venv` is missing, show a visible warning in Neovim

Important repo-specific detail:

- There is both a root `requirements.txt` and a nested `scripts/crawl_sharepoint/requirements.txt`
- The nested requirements file appears to confuse root detection
- The fix should handle this cleanly rather than relying on manual activation

Suggested direction for the fix:

- Adjust `basedpyright` or Pyright root detection so the repo root is preferred over nested `requirements.txt`
- Explicitly configure the Python interpreter to use repo-local `.venv/bin/python`
- Add a Neovim warning or notification when opening a Python project that lacks `.venv`

Success criteria:

- `:LspInfo` shows the repo root, not `scripts/crawl_sharepoint`
- LSP resolves installed packages from `.venv`
- No import warning for `dotenv`
- No manual activation required
- Warning appears if `.venv` does not exist

When this task is complete, ask me to confirm it is solved, then remove this file.
