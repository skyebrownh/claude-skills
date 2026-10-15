# Process migrations

Each project records which version of Skye's process it was set up for, under **Process version** in its `.claude/workflow.md`. When this repo changes something that projects set up earlier also need (a renamed heading in `workflow.md`, a line in an issue template), the change gets a new version here, with the steps that bring a project from the version before it.

- **The current version** is the newest heading below. `/setup-project` writes it into new projects, and `/ship` and `/merge` compare a project's version with it.
- **A project with no Process version section** is on version 1.
- **A project is behind** when its version is lower than the current one. It needs every migration above its version, applied in order.

## How to apply a migration

Each change names a file, the text it expects to find there, and what to do. Apply it only if the expected text is there **exactly**. If it isn't, the project has probably been customised, so stop and ask Skye what to do rather than overwriting her change. A change marked "if the file exists" is skipped, with a note, when the project doesn't have that file.

`/setup-project` shows every pending change together, applies them only after Skye approves, and sets **Process version** last, so a project that stops partway still reads as behind.

New migrations go at the bottom, numbered one higher than the last.

## 1: Starting point

The process as it stood before versions existed (before #14). There's nothing to change.

## 2: Parent PRs

**Why:** `/ship` and `/merge` now ship a parent issue's children together as a "parent PR" (#3), and projects record their process version (#14).

**Changes:**

1. **`.claude/workflow.md`**, under `## Merging`: replace `- Multi-issue PR:` with `- Parent PR:`, keeping the rest of the line.
2. **`.github/ISSUE_TEMPLATE/parent.md`**, if the file exists and has no `**Ships as:**` line: under `## Directive`, after its comment, add a blank line and then:

   ```markdown
   **Ships as:** <!-- one PR / one PR per child -->
   ```

   Then tell Skye that any **open** parent issue also needs a `**Ships as:**` line before `/ship` will run on its branch. `/setup-project` doesn't edit issues.
3. **`.claude/workflow.md`**: add the `## Process version` section from [workflow-template.md](workflow-template.md) directly above `## Default branch`, holding `2`.
