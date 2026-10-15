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

## 2026-10-15: Issues and PRs for this repo too

This repo now uses the same issue → plan → PR loop as heritage-media-availability (#2), so every change to a skill has a recorded reason that later changes can look back on. It has feature, bug and parent issue templates (blank issues off), a PR template, a short CLAUDE.md, and a `.claude/workflow.md`, so `/ship` and `/merge` run here as in any other project. Merging deploys nothing in the usual sense, but see the next entry.

The parent template's `Ships as:` line (one PR, or one PR per child) is what `/ship` reads to decide how a parent's children become PRs (#3). Parent issues get no label, so the repo needed no new one.

## 2026-10-15: Switch back to `main` before using skills elsewhere

Installed skills are symlinks into this folder, so the branch checked out here is the version every project runs. The habit: `git switch main` here before using the skills in another project, and leave `main` checked out between issues.

Considered and left for now: a separate live clone, or git worktrees (a second checkout of the repo in another folder) so that feature branches never touch the installed copy. Worktrees are the fix if the habit ever causes trouble, such as a project running a half-finished skill.

## 2026-10-15: Parent and child issues replace `/ship-set`

heritage-media-availability's `/ship-set` shipped a branch for several issues. GitHub now records parent/child (sub-issue) and blocked-by links as data, so `/ship` reads those instead (#3). A parent's `**Ships as:**` line decides how its children become PRs:

- **one PR per child** (the default): each child is a vertical slice, a thin piece that works end to end on its own, with its own branch and PR. The idea comes from Matt Pocock's skills ([mattpocock/skills](https://github.com/mattpocock/skills), MIT). The child's PR says `Part of #P`.
- **one PR:** `/ship <child#>` commits each child on the parent's branch, and a final `/ship` opens one PR that closes the parent and every child. `/merge` uses the project's **Parent PR** style (rebase here, so each child's commit stays on `main`).

Choices worth remembering:

- **No `Ships as:` line means stop.** How the work ships is Skye's call, not a default to guess.
- **A child can have more than one commit.** A fix to an earlier child found while working on a later one becomes `<child title> (follow-up)`, rather than a new child issue or an amended commit (history is never rewritten).
- **Blocked children stop `/ship`,** except that on a parent's branch a sibling already committed there counts as done: it can't close until the shared PR merges.
- The `workflow.md` wording changed from "Multi-issue PR" to "Parent PR".
- Handovers come from the conversation for now. Once `/handover` exists (#8), `/ship` reads only the issue's latest `## Handover` comment, so it never depends on which session runs it.

## 2026-10-15: Process versions and migrations keep projects in step

Changing this repo can leave projects set up earlier behind: after #3, heritage-media-availability's `workflow.md` still said `Multi-issue PR:`. Each project now records a **Process version**, and `skills/workflow/setup-project/migrations.md` lists numbered migrations, each saying what to change in a project and why (#14). It's the same idea as database migrations: apply every one above the project's version, in order, then record the new version.

Choices worth remembering:

- **The current version is the newest heading in `migrations.md`,** so the number lives in one place. A project with no version counts as version 1, the process before #14.
- **`/ship` and `/merge` stop when a project is behind,** rather than running on facts that may no longer mean what they expect. They read `migrations.md` from `/setup-project`'s folder, because skills only Skye starts can't call each other.
- **Each change names the text it expects,** and a mismatch stops and asks instead of overwriting, because it likely means the project was customised.
- **`/setup-project` applies the migrations,** rather than a separate `/align` skill: it already writes `workflow.md`, and keeping one owner for that file avoids two skills disagreeing about it.

## 2026-10-15: A review skill that only reports

`fresh-eyes` gives the work a fresh-context review before the handover, or reads a document such as a spec cold (#5). It never changes a file: deciding what to act on stays with Skye.

Borrowed, and rewritten in Skye's conventions:

- **Matt Pocock's `code-review`** ([mattpocock/skills](https://github.com/mattpocock/skills), MIT): the two axes, run as parallel subagents so neither colours the other (**Standards**: the project's own rules; **Issue**, his "Spec": what the issue asked for), and the baseline of Fowler code smells in `smells.md`, which are always judgement calls and give way to the project's CLAUDE.md.
- **pstack's `interrogate`** by Lauren Tan ([cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack), MIT): the lead reviewer who checks each finding rather than passing it on, the **Act on / Consider / Noted** buckets, and, for documents, a cold reader that gets none of the conversation.

Choices worth remembering:

- **The diff includes uncommitted and untracked files.** Review runs before the handover, when nothing is committed yet, so it compares the working tree with the point where the branch left the default branch.
- **Claude may start it,** unlike `/ship` and `/merge`: it only reads, so it needs no approval, and `/handover` (#8) and `/new-project` (#9) can call it.
- **Named `fresh-eyes`, not `review`,** because Claude Code has a built-in `/review` command, and a clash would make it unclear which one runs.
- **Document mode doesn't need `workflow.md`,** so `/new-project` can check a spec before `/setup-project` has run.
- **Findings judged wrong are dropped with a one-line note,** in place of pstack's Dismissed bucket, so the report stays short but Skye can still overrule a drop.

Left out: multi-model review (pstack's reviewers run on different models; here both run on the same one), the Dismissed bucket, and blast radius (what else a change could break).
