# claude-skills

Skye's personal Claude Code skills: the workflow she uses in every project, kept in one repo so it can be refined over time and set up in a new project in minutes.

Each skill is a folder holding a `SKILL.md`, which Claude Code reads as instructions for one task. The skills hold **how Skye works**. Facts about a particular project (its test command, whether merging deploys) live in that project's `.claude/workflow.md`, which `/setup-project` writes. That split is what lets the same skills work everywhere.

## Skills

### Started only by Skye

These act outside the conversation (commit, push, merge), so typing the command is the approval.

| Skill | What it does |
| --- | --- |
| [`/setup-project`](skills/workflow/setup-project/SKILL.md) | Interviews Skye and writes the project's `.claude/workflow.md`. Run once per project, before `/ship` and `/merge`, and again to bring a project up to date when the process changes. |
| [`/ship`](skills/workflow/ship/SKILL.md) | Commits the reviewed work on an issue's branch, pushes it, and opens the PR. Never merges. A parent issue's `Ships as:` line decides how its children ship: one PR per child (each from its own branch), or one PR, where `/ship <child#>` commits each child on the parent's branch and a final `/ship` opens the PR. |
| [`/merge <PR#>`](skills/workflow/merge/SKILL.md) | Merges an approved PR, cleans up the branch, and lists what to check after the deploy. |

### Claude may also start

| Skill | What it does |
| --- | --- |
| [`/handover`](skills/workflow/handover/SKILL.md) | Hands the committed work on an issue's branch over for review: runs the checks and `fresh-eyes`, and posts a `## Handover` comment on the issue recording the commit it covers, with what changed, the test results and manual test steps. |
| [`grilling`](skills/guides/grilling/SKILL.md) | Interviews Skye in rounds of numbered questions with recommended answers, looking facts up itself, until every decision is settled. |
| [`tdd`](skills/guides/tdd/SKILL.md) | Builds test-first in thin red-green slices, testing behaviour through public paths, with the behaviours to test taken from the approved plan. |
| [`writing-skills`](skills/authoring/writing-skills/SKILL.md) | The style guide for writing and editing skills and CLAUDE.md files. |
| [`fresh-eyes`](skills/guides/fresh-eyes/SKILL.md) | A fresh-context review that only reports. Code mode: two reviewers check the branch against the project's standards and against the issue. Document mode (given a path, such as `SPEC.md`): a cold reader looks for gaps. Findings come back sorted into Act on, Consider and Noted. |

## Install

```sh
./install.sh                  # link every skill into ~/.claude/skills
./install.sh writing-skills   # link only the skills named
./install.sh --dry-run        # show what would happen, change nothing
./install.sh --uninstall      # remove every link this repo made
```

The script makes **symlinks** (pointers to the folders in this repo) instead of copies, so editing a skill here, or running `git pull`, updates it everywhere. Re-run the script after adding, renaming or removing a skill. It never overwrites a real folder, or a link it didn't make (it stops and tells you instead).

**Name clashes:** a personal skill overrides a project's own skill with the same name. Linking `ship` here hides a project's `.claude/skills/ship`, so switch a project over (run `/setup-project`, then remove its own copy) before linking a skill that clashes with one of its skills.

## Using it in a project

1. `./install.sh` (once per machine, and after adding skills).
2. In the project, run `/setup-project` and approve the `workflow.md` it drafts.
3. Commit `.claude/workflow.md` with the project's next reviewed change.

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
tests/           tests for install.sh
.github/         issue and PR templates
CLAUDE.md        how changes to this repo are made (issue → plan → PR)
DECISIONS.md     why things are the way they are, and where ideas came from
```

Add a new bucket when a group of skills doesn't fit an existing one. Skill names must be unique across buckets, because Claude Code finds a skill by its folder name.

## Adding or changing a skill

1. Start a draft in `skills/in-progress/<name>/` from [the template](skills/authoring/writing-skills/skill-template.md), following [`writing-skills`](skills/authoring/writing-skills/SKILL.md).
2. Try it in a real or throwaway project. A draft can be tried by copying its folder into that project's `.claude/skills/`.
3. Move it into a bucket, list it in this README, and run `./install.sh <name>`.
4. Record anything worth remembering (a choice made, an idea borrowed) in [DECISIONS.md](DECISIONS.md).

## Tests

```sh
bash tests/test_install.sh
```

The tests run `install.sh` against temporary folders, never your real `~/.claude/skills`. Skills themselves have no automated tests: try a changed skill in a project before relying on it.
