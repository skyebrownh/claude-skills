# claude-skills

Skye's personal Claude Code skills. README explains what each skill does, how `install.sh` links them, and the folder layout. Read it before changing a skill.

## How work happens here

Every change starts from a GitHub issue, so it has a recorded reason.

1. **Issue.** Skye runs `/draft-issue`, which drafts it from a template in `.github/ISSUE_TEMPLATE/` (feature, bug, or parent for work split into child issues) and creates it only once she approves the draft.
2. **Plan** with `/plan-issue <N>`: it shows the plan in chat, grills Skye on the open decisions, and posts it on the issue under `## Plan (approved)` once she approves.
3. **Build** with `/build <N>`: it makes the branch `<issue#>-<short-slug>` (e.g. `2-issues-and-prs`) and commits on it as the work goes, never pushing. Ideas that come up mid-issue become a new issue, not extra scope.
4. **Hand over** with `/handover`, which posts a `## Handover` comment on the issue for the commit it covers. Revisions are new commits, then a new handover. Then wait for Skye's review.
5. **`/ship`** pushes the branch and opens the PR from `.github/pull_request_template.md`; **`/merge <PR#>`** merges it. Only Skye starts `/draft-issue`, `/build`, `/ship` and `/merge`.

Project facts for these skills (checks, merge style, whether merging deploys) are in `.claude/workflow.md`; update it with `/setup-project`.

## Writing skills

Follow the `writing-skills` skill for every SKILL.md and for this file. Ideas borrowed from someone else's skills are credited in DECISIONS.md, along with any choice worth remembering, newest last with the date.

## Tests

```sh
bash tests/test_install.sh
```

These cover `install.sh` only (they use temporary folders, never the real `~/.claude/skills`). Skills have no automated tests, so try a changed skill in a real or throwaway project.

## Switch back to `main` before using skills elsewhere

Installed skills are symlinks into this folder, so whatever branch is checked out here is the version every project runs. Before using skills in another project, run `git switch main` here, so they run the reviewed version rather than half-finished work. Leaving `main` checked out between issues keeps this simple.
