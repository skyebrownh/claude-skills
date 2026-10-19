# Shipping committed branches

Issue: #20

Replaced in part by: [2026-10-18-232724-fixing-conflicts-on-the-branch](2026-10-18-232724-fixing-conflicts-on-the-branch.md): a conflicting fold is resolved and committed without waiting for Skye's OK, and she reviews it in the new handover.

`/ship` (#20) now pushes work that `/build` committed and `/handover` recorded, rather than committing reviewed changes itself. Typing it is the approval to push and open the PR.

- **The handover comment is the proof of review.** `/ship` checks that the issue's latest `## Handover` names the branch tip's exact commit, so it works from any session, and a commit added after the review stops it.
- **A "one PR" parent's children are squash-folded** into the parent's branch, one commit each with the child's title, so the parent PR still rebases into one commit per child on `main`, however many commits each build made. The child's branch is deleted after the fold: it was never pushed, and its work is now the fold commit.
- **A fold conflict waits for Skye.** `git merge --squash` stages without committing, so Claude can resolve the conflict and show it before anything is written to history.
- **No more `(follow-up)` commits.** A fix to a folded child is a new child issue, so every commit on the parent's branch has one plan and one handover behind it.
- **The parent lookup is written once,** in `ship/finding-the-parent.md`, which `/ship`, `/build` and `/handover` all point to, with the same stop cases.
- **Migration 3 matches heritage-media-availability's exact lines,** the only project set up before it. Any other project's wording won't match, so the migration stops and asks there instead of guessing. Other lines about the old process are listed for Skye to edit, not rewritten.
- **`writing-skills`' rule for Skye-only skills is now about what's hard to undo** (pushing, merging, publishing, deleting), not committing: a local commit can be revised before it's pushed, which is what lets `/handover` commit its fixes.
- **#20 was built with `/build 20`.** Once its `/ship` was in the working tree, the old way (uncommitted work, handover in chat) couldn't have shipped it.
