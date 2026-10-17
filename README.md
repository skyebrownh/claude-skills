# claude-skills

Skye's personal Claude Code skills: the workflow she uses in every project, kept in one repo so it can be refined over time and set up in a new project in minutes.

Each skill is a folder holding a `SKILL.md`, which Claude Code reads as instructions for one task. The skills hold **how Skye works**. Facts about a particular project (its test command, whether merging deploys) live in that project's `.claude/workflow.md`, which `/setup-project` writes. That split is what lets the same skills work everywhere.

## Skills

### Started only by Skye

Each one does something that's hard to undo (creating a repo, creating issues, building and committing, pushing, merging), or is something Skye chooses the moment for, so typing the command is Skye's approval for it.

| Skill | What it does |
| --- | --- |
| [`/new-project <idea>`](skills/workflow/new-project/SKILL.md) | Sets up a brand-new project from an idea, in its own folder, one approved phase at a time: restate, grill, compare the big choices, write SPEC.md, challenge it with `fresh-eyes`, write CLAUDE.md and README.md, create the private GitHub repo with its templates, labels and milestones, write `workflow.md` through `/setup-project` and push the first commit. It ends with a `/draft-issue` line for the first issues. |
| [`/draft-issue <idea> …`](skills/workflow/draft-issue/SKILL.md) | Turns one idea, or several, into draft issues from the project's templates, after a short `grilling`: a parent with vertical-slice children for bigger work, and a suggested comment instead where an issue already exists. Creates nothing until Skye approves the drafts. |
| [`/build <N> …`](skills/workflow/build/SKILL.md) | Builds approved issues on their own branches, committing each green slice, and hands each over with `/handover`. One issue builds in this folder; several build in parallel, one subagent each in a temporary worktree. Never pushes. |
| [`/ship [<N> …]`](skills/workflow/ship/SKILL.md) | Pushes each issue's committed branch and opens its PR, once its latest handover covers the branch tip. Never merges. A parent issue's `Ships as:` line decides how its children ship: one PR per child, or one PR, where `/ship <child#>` folds each child's branch into the parent's branch as one commit, and `/ship <parent#>` opens the PR. |
| [`/merge <PR#>`](skills/workflow/merge/SKILL.md) | Merges an approved PR, cleans up the branch, and lists what to check after the deploy. |
| [`/whats-next`](skills/workflow/whats-next/SKILL.md) | Recommends what to work on next, from a clean and up-to-date default branch: one subagent reads the open issues, finishes started work first and respects blockers and parents' order, and shows the next issue with its command, plus up to four more. Changes nothing. |
| [`/retro`](skills/authoring/retro/SKILL.md) | Looks back over the current session in a subagent for Skye's corrections and steps that went wrong, keeps the ones that will happen again, and names each one's fix at the highest level: a check or test, then a skill change, then a CLAUDE.md line. Changes nothing: it ends with a `/draft-issue` line per repo. |

### Claude may also start

| Skill | What it does |
| --- | --- |
| [`/setup-project`](skills/workflow/setup-project/SKILL.md) | Interviews Skye (when she asks, or from `/new-project`) and writes the project's `.claude/workflow.md`. Run once per project, before `/ship` and `/merge`, and again to bring a project up to date when the process changes. |
| [`/plan-issue <N> …`](skills/workflow/plan-issue/SKILL.md) | Turns issues into plans: reads the issue, its parent, the spec and the affected code, weighs two approaches for non-trivial work, shows each plan in chat and grills Skye on what's open, then posts `## Plan (approved)` on the issue once she approves. Creates no branch. |
| [`/handover`](skills/workflow/handover/SKILL.md) | Hands the committed work on an issue's branch over for review: runs the checks and `fresh-eyes`, and posts a `## Handover` comment on the issue recording the commit it covers: a line per changed file, the test results, the review (what needs Skye's decision, what was fixed and how, and what was dropped and why) and manual test steps. Chat shows the same text. |
| [`grilling`](skills/guides/grilling/SKILL.md) | Interviews Skye in rounds of numbered questions with recommended answers, looking facts up itself, until every decision is settled. |
| [`tdd`](skills/guides/tdd/SKILL.md) | Builds test-first in thin red-green slices, testing behaviour through public paths, with the behaviours to test taken from the approved plan. |
| [`writing-skills`](skills/authoring/writing-skills/SKILL.md) | The style guide for writing and editing skills and CLAUDE.md files. |
| [`fresh-eyes`](skills/guides/fresh-eyes/SKILL.md) | A fresh-context review that only reports. Code mode: two reviewers check the branch against the project's standards and against the issue. Document mode (given a path, such as `SPEC.md`): a cold reader looks for gaps. Findings come back as Fix (each with a suggested fix), Needs you (each with a recommendation), and Dropped (each with why). |

## Install

```sh
./install.sh                  # link every skill into ~/.claude/skills, and the global CLAUDE.md
./install.sh writing-skills   # link only the skills named
./install.sh --dry-run        # show what would happen, change nothing
./install.sh --uninstall      # remove every link this repo made
```

The script makes **symlinks** (pointers to the folders in this repo) instead of copies, so editing a skill here, or running `git pull`, updates it everywhere. Re-run the script after adding, renaming or removing a skill. It never overwrites a real folder or file, or a link it didn't make (it stops and tells you instead).

**The global CLAUDE.md:** Skye's preferences for every project live in [`global/CLAUDE.md`](global/CLAUDE.md), so changing them goes through an issue and a PR like any skill. A full `./install.sh` links it to `~/.claude/CLAUDE.md`; naming skills leaves it alone. If `~/.claude/CLAUDE.md` is still a real file, the script says how to move it in: copy any changes into `global/CLAUDE.md`, remove the file, and run the script again.

**Both follow the checked-out branch.** The links point into this folder, so whichever branch is checked out here is the version of the skills, and of the global CLAUDE.md, that every project uses.

**Name clashes:** a personal skill overrides a project's own skill with the same name. Linking `ship` here hides a project's `.claude/skills/ship`, so switch a project over (run `/setup-project`, then remove its own copy) before linking a skill that clashes with one of its skills.

## Using it in a project

1. `./install.sh` (once per machine, and after adding skills).
2. In the project, run `/setup-project` and approve the `workflow.md` it drafts.
3. Commit `.claude/workflow.md` with the project's next change.

For a brand-new project, `/new-project` does steps 2 and 3, along with the spec, CLAUDE.md, README, repo and first commit.

Then each issue goes: `/draft-issue`, `/plan-issue <N>`, `/build <N>` (commits on its branch, ends with `/handover`), review the branch from the handover, `/ship <N>`, `/merge <PR#>`.

### Keeping projects up to date

Most changes here reach every project at once, through the symlinks. Some don't: a project's own files, such as its `workflow.md` or its issue templates, were written for the process as it was when it was set up. So each project's `workflow.md` records a **Process version**, and [`migrations.md`](skills/workflow/setup-project/migrations.md) lists, for each version, what changes in a project to reach it.

When a project is behind, `/ship` and `/merge` stop and say which migrations it's missing. Running `/setup-project` there shows those changes, applies them once Skye approves, and updates the version. A change here that leaves projects out of date needs a new migration (the PR template's checklist asks).

## Layout

```
skills/
  workflow/      the issue → PR → merge loop
  authoring/     writing and maintaining skills
  guides/        how Claude does recurring tasks; other skills build on them
  in-progress/   drafts; never installed
global/          CLAUDE.md, Skye's preferences for every project
tests/           tests for install.sh
.github/         issue and PR templates
CLAUDE.md        how changes to this repo are made (issue → plan → PR)
decisions/       why things are the way they are, and where ideas came from
```

Add a new bucket when a group of skills doesn't fit an existing one. Skill names must be unique across buckets, because Claude Code finds a skill by its folder name.

## Adding or changing a skill

1. Start a draft in `skills/in-progress/<name>/` from [the template](skills/authoring/writing-skills/skill-template.md), following [`writing-skills`](skills/authoring/writing-skills/SKILL.md).
2. Try it in a real or throwaway project. A draft can be tried by copying its folder into that project's `.claude/skills/`.
3. Move it into a bucket, list it in this README, and run `./install.sh <name>`.
4. Record anything worth remembering (a choice made, an idea borrowed) in a new file in [`decisions/`](decisions/README.md).

## Tests

```sh
bash tests/test_install.sh
```

The tests run `install.sh` against temporary folders, never your real `~/.claude/skills` or `~/.claude/CLAUDE.md`. Skills themselves have no automated tests: try a changed skill in a project before relying on it.
