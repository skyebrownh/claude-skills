# .gitignore starters

`/new-project` builds a project's `.gitignore` in its phase 7 from these blocks: **Common** always, then the block for each language in the stack chosen in phase 3. A stack with no block here gets Common only, plus the lines its own tools document, each with a comment like the ones below. Copy the lines inside each code block, comments included, so the file explains itself.

## Common

```gitignore
# Secrets: real values live only in .env locally and in the host's settings.
# .env.example, with placeholder values only, is committed instead.
.env

# macOS folder metadata
.DS_Store

# Editor settings, which differ per person
.vscode/
.idea/
```

## Python (uv)

```gitignore
# The virtual environment uv makes; rebuilt from uv.lock with `uv sync`
.venv/

# Compiled bytecode, rebuilt on every run
__pycache__/
*.py[cod]

# Test and coverage output
.pytest_cache/
.coverage
htmlcov/
```

## Node

```gitignore
# Installed packages; rebuilt from the lockfile with `npm install`
node_modules/

# Build output, rebuilt on every build or deploy
dist/
build/

# npm's debug logs
npm-debug.log*
```
