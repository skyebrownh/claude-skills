# Project facts live in `.claude/workflow.md`

Skills hold the process, which is the same in every project. Anything that differs by project (the checks to run before committing, the PR template, the merge style, whether merging deploys and where, what to check after a deploy, when to suggest a release) lives in a short Markdown file in the project, written by `/setup-project`. Skills read it by section heading.

- Markdown rather than YAML or JSON, so Skye can read and edit it, and comments can explain each section.
- A skill stops when a fact is missing, rather than guessing. A wrong guess at "does merging deploy?" is the costly kind.
- The branch naming rule (`<issue#>-<slug>`) and the commit message rule (the issue's title) are in the skills, not `workflow.md`: they're how Skye works everywhere.
