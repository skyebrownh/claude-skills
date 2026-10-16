# Symlinks, not copies or a plugin

`install.sh` links each skill folder into `~/.claude/skills`, so the repo is the only copy and `git pull` updates everything. A Claude Code plugin was considered and left for later: it adds a manifest and versioning that a one-person repo doesn't need yet.

A personal skill overrides a project skill with the same name (Claude Code's rule: enterprise over personal, personal over project). So `install.sh` can link named skills only, and a project with its own `ship` or `merge` is switched over before the personal ones are linked.
