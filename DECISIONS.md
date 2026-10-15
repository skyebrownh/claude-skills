# Decisions

Choices about how these skills work, newest last, with the date and the reason. Ideas borrowed from other people's skills are credited here.

## 2026-10-15: Start a personal skills repo

The workflow built for heritage-media-availability (spec → issue → plan → build → handover → `/ship` → `/merge`) is worth reusing in new projects. Two popular published collections were reviewed first:

- **Matt Pocock's skills** ([mattpocock/skills](https://github.com/mattpocock/skills), MIT). The closest fit. Borrowed the repo shape (skills grouped into bucket folders, symlinked into `~/.claude/skills` by a script), the split between skills Claude may start and skills only the human starts, the per-project setup skill, and the writing rules in `writing-skills`. Not adopted wholesale: some of his skills commit or create issues without an approval step, and his vocabulary differs from Skye's.
- **pstack** by Lauren Tan ([cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack), MIT). Built for Cursor, many agents working in parallel, and acting without asking, which conflicts with Skye's approval gates. Kept as a source of ideas for later (an adversarial review step, putting a skill's steps on the task list, turning repeated corrections into skill edits).

Decided: build Skye's own skills, rewriting borrowed ideas in her own words and conventions, rather than installing either collection.

## 2026-10-15: Project facts live in `.claude/workflow.md`

Skills hold the process, which is the same in every project. Anything that differs by project (the checks to run before committing, the PR template, the merge style, whether merging deploys and where, what to check after a deploy, when to suggest a release) lives in a short Markdown file in the project, written by `/setup-project`. Skills read it by section heading.

- Markdown rather than YAML or JSON, so Skye can read and edit it, and comments can explain each section.
- A skill stops when a fact is missing, rather than guessing. A wrong guess at "does merging deploy?" is the costly kind.
- The branch naming rule (`<issue#>-<slug>`) and the commit message rule (the issue's title) are in the skills, not `workflow.md`: they're how Skye works everywhere.

## 2026-10-15: Symlinks, not copies or a plugin

`install.sh` links each skill folder into `~/.claude/skills`, so the repo is the only copy and `git pull` updates everything. A Claude Code plugin was considered and left for later: it adds a manifest and versioning that a one-person repo doesn't need yet.

A personal skill overrides a project skill with the same name (Claude Code's rule: enterprise over personal, personal over project). So `install.sh` can link named skills only, and a project with its own `ship` or `merge` is switched over before the personal ones are linked.

## 2026-10-15: First version is ship, merge, setup-project and writing-skills

Generalised from heritage-media-availability's `/ship` and `/merge` (its issue #69), keeping their safety rules: check everything before acting, stop at the first problem, stage only the files in the handover, never rewrite history, never merge from `/ship`, and never create a release without separate approval.

Not yet included, in the planned order:

1. Fold heritage-media-availability's `/ship-set` (branches for several issues) into `/ship` as a second mode.
2. Turn the rest of the loop, now prose in that project's CLAUDE.md, into skills: `/draft-issue` (with a grilling interview first), `/plan-issue`, `/handover`.
3. Rewrite in Skye's conventions: grilling, a two-part code review (her standards, and the issue's acceptance criteria), diagnosing bugs, and teach.
4. Switch heritage-media-availability over: give it a `workflow.md` and remove its own `ship` and `merge`.

Skills specific to one project (`/pilot-feedback`, `/refresh-staging`) stay in that project.
