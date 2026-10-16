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

## 2026-10-15: Grilling and tdd guides

Two guides that Claude may start on its own, and that other skills build on, in a new `skills/guides/` bucket (#4). Both are adapted from Matt Pocock's `grilling` and `tdd` ([mattpocock/skills](https://github.com/mattpocock/skills), MIT).

- **`grilling`** keeps his design tree and frontier: each round asks every question whose parents are settled, with no limit on how many, and facts are looked up by subagents rather than asked. It replaces `/setup-project`'s own interview rules, including its "at most four questions" limit, because holding questions back only adds rounds. Added: each recommended answer names its source, and the interview ends only when Skye confirms nothing is left open, followed by a summary of the decisions.
- **`tdd`** keeps his idea of a good test (behaviour through public paths), his three anti-patterns (implementation-coupled, tautological, horizontal slicing) and his "mock only at system boundaries" rule, narrowed to external services, time and randomness, with a test database preferred to a mocked one. `good-tests.md` rewrites his examples in Python and JavaScript, Skye's languages.

Where `tdd` differs from his:

- **The test plan comes from the approved plan,** rather than confirming the seams to test with Skye separately. She already approved what the work should do, so a second approval would repeat it. A test the plan didn't foresee is fine if it tests planned behaviour, and is listed in the handover; a new behaviour becomes a new issue.
- **Refactoring happens inside the loop, while green,** with the tests re-run after each change. His version leaves refactoring to a later review stage; tidying while the code is fresh and the tests are passing is cheaper, and the tests prove nothing changed.

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

## 2026-10-15: Handovers live on the issue

`/handover` (#8) records each handover as a `## Handover` comment on the issue, naming the commit it covers (the branch tip). It's the first child of #18, which lets Claude commit on feature branches during the build.

- **The handover names its commit,** so `/ship` (#20) can check, from any session, that the branch hasn't moved since Skye reviewed it. Before, the handover lived in the conversation, so only the session that built the work could ship it.
- **It covers committed work only,** and stops if anything is uncommitted or untracked: what Skye reviews must be exactly what gets pushed.
- **No suggested commit message any more:** commits are made during the build, and the squash merge takes the issue's title.
- **Claude may start it,** unlike `/ship` and `/merge`: posting a comment on the issue is a record, not an approval, and `/build` (#19) calls it at the end of every build.
- **Fresh-eyes findings:** Act on findings within the approved plan are fixed before the handover, one commit each, so Skye can see each fix and revert it alone. Everything else is listed untouched, so she can overrule the judgement. This is how `fresh-eyes`, which never changes a file, fits a step that does.
- **Files are plain paths in the comment,** not links, because the branch stays local until `/ship`, so a GitHub link would be broken.
- **A `Manual test setup` section in `workflow.md`** holds what Skye does before trying a change by hand, so each handover's steps don't have to work it out again. Projects set up earlier get it through migration 3 (#20).

## 2026-10-15: Building on branches, in parallel

`/build <N> …` (#19) builds approved issues on their own branches, committing each green slice, and ends with `/handover`. Several issues build at once, one subagent each in a worktree.

- **Handovers run in the main session,** not in the subagents. Subagents can't start subagents, and `fresh-eyes` needs two, so a subagent's own review would lose the fresh context that makes it worth having. Each subagent builds and commits; the main session hands each branch over, from its worktree.
- **`/build` makes the worktrees itself** with `git worktree add`, rather than through the Agent tool's `isolation: worktree`. That option picks its own branch name and base, and `/build` needs `<N>-<slug>` from the right base (the parent's branch, for a child of a "one PR" parent), and a worktree that lasts until its handover is posted.
- **Worktrees live in `.claude/worktrees/<N>`,** listed in `.git/info/exclude` (this clone's own ignore file, never committed), so they never show up as untracked files in Skye's folder.
- **Branches are created with `--no-track`.** A branch made from `origin/main` otherwise tracks `main`, so a plain `git push` could send its work there; `/ship` sets the real upstream when it pushes.
- **Build order follows blockers:** `/build` stops if one listed issue blocks another, rather than ordering them itself, because the blocked one needs the other's work to have landed (or, for siblings, been committed on the parent's branch) before it starts.
- **The sibling rule:** a child blocked by a sibling under the same "one PR" parent can be built once that sibling's commit is on the parent's branch, found by its title, because the sibling stays open until the parent's PR merges.
- **Revisions on another branch** go to a subagent in a worktree, so Skye's folder never switches branch under her while she reviews.

## 2026-10-16: Shipping committed branches

`/ship` (#20) now pushes work that `/build` committed and `/handover` recorded, rather than committing reviewed changes itself. Typing it is the approval to push and open the PR.

- **The handover comment is the proof of review.** `/ship` checks that the issue's latest `## Handover` names the branch tip's exact commit, so it works from any session, and a commit added after the review stops it.
- **A "one PR" parent's children are squash-folded** into the parent's branch, one commit each with the child's title, so the parent PR still rebases into one commit per child on `main`, however many commits each build made. The child's branch is deleted after the fold: it was never pushed, and its work is now the fold commit.
- **A fold conflict waits for Skye.** `git merge --squash` stages without committing, so Claude can resolve the conflict and show it before anything is written to history.
- **No more `(follow-up)` commits.** A fix to a folded child is a new child issue, so every commit on the parent's branch has one plan and one handover behind it.
- **The parent lookup is written once,** in `ship/finding-the-parent.md`, which `/ship`, `/build` and `/handover` all point to, with the same stop cases.
- **Migration 3 matches heritage-media-availability's exact lines,** the only project set up before it. Any other project's wording won't match, so the migration stops and asks there instead of guessing. Other lines about the old process are listed for Skye to edit, not rewritten.
- **`writing-skills`' rule for Skye-only skills is now about what's hard to undo** (pushing, merging, publishing, deleting), not committing: a local commit can be revised before it's pushed, which is what lets `/handover` commit its fixes.
- **#20 was built with `/build 20`.** Once its `/ship` was in the working tree, the old way (uncommitted work, handover in chat) couldn't have shipped it.

## 2026-10-16: Drafting issues from ideas

`/draft-issue` (#6) turns ideas into issues from the project's own templates, after a short `grilling`, and creates them only once Skye approves the drafts.

- **Only Skye starts it,** because creating an issue publishes it: it's public at once and notifies anyone watching. Typing the command approves drafting only; creating needs her approval of the drafts in chat.
- **Drafts are shown together, and nothing is created before approval.** Anything she doesn't mention counts as not approved, so Claude asks rather than assuming.
- **Several ideas in one run** become separate drafts, each approved on its own, with one grilling for all of them (questions numbered per idea, such as 1.1 and 2.1) so she answers in one reply. Combining two related ideas is suggested, never done for her.
- **Ships as is never guessed.** For a new parent it's recommended with a reason, as a question, the same rule `/ship` follows.
- **The duplicate check and the multi-item split** come from heritage-media-availability's `pilot-feedback`: open and closed issues are searched for each idea, and a match becomes a suggested comment instead of a new issue.
- **Existing labels and milestones only.** A label that doesn't exist yet is a separate question, because creating one changes the repo for every issue after it.
- **It needs no `workflow.md`:** templates, labels and SPEC.md are found by looking, so it works in a new project before `/setup-project`.
- **Planning is handed to `plan-issue`** (#7). If Skye asks to plan what was created, it follows `plan-issue` for those issues; otherwise it suggests it.

## 2026-10-16: Planning issues with `/plan-issue`

`/plan-issue <N> …` (#7) turns issues into plans Skye approves, and posts each as `## Plan (approved)` on its issue, where `/build` reads it.

- **Claude may start it,** unlike `/build`: it only reads until Skye approves the plan, so starting it needs no approval of its own. That is also what lets `/draft-issue` (#6) hand over to it when Skye asks to plan the issues it created.
- **It runs without `workflow.md`,** unlike the skills that act: a missing fact there would make `/build` or `/ship` guess a command, but a plan only names the checks, so it says they come from `/setup-project` and carries on.
- **The plan names no branch.** `/build` makes the branch, from the right base, when the build starts, so a name written at planning time could only disagree with it.
- **Non-trivial work gets two approaches** with their trade-offs and a recommendation, so Skye chooses between real options rather than approving the first idea. Trivial work gets one line on why one approach is enough.
- **A prototype is suggested, not built.** When a decision needs one, the plan recommends it and says what it would answer. Building it is separate work (a prototype skill comes later).
- **Plans are written out in full in the chat before any question,** and again after each round of answers. Skye approves what she reads in the chat, and a plan saved only to a file had left her with nothing to approve.

## 2026-10-16: The global CLAUDE.md lives here

`~/.claude/CLAUDE.md`, Skye's preferences for every project, moved into `global/CLAUDE.md` (#11), and `install.sh` links it like a skill.

- **It gets history and review,** like any skill. Before, it was edited by hand, so a change had no issue, no diff and no way back.
- **`install.sh` never replaces a real file there,** or another tool's link. It says how to move the file in instead (copy any changes across, remove it, run again), because replacing it could lose a change not yet copied into the repo.
- **Only a full install links it.** Naming skills means "only these", and the Manual test setup has Skye run `./install.sh <name>` to try a branch's new skill, which shouldn't also swap her preferences.
- **It follows the checked-out branch,** like the skills. A branch cut before #11 merged has no `global/CLAUDE.md`, so on one the link points at nothing and Claude Code runs without global preferences until she switches back.
- **Slimmed to what's true in every project:** tighter wording, the `--body-file` line dropped (the skills do it), and the Git rules merged with "ask before deleting" into one Approvals (always) section. The plan-first line and the review list stay until their own issues replace them.
- **`--help` prints the top comment up to its first blank line,** rather than a fixed line range, which the longer usage had outgrown.
