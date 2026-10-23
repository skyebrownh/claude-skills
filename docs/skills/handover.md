# `/handover`

Hands the committed work on an issue's branch over for your review. It runs the project's checks and a `fresh-eyes` review, then posts a `## Handover` comment on the issue that names the exact commit it covers.

For the exact steps, see its [SKILL.md](../../skills/workflow/handover/SKILL.md).

## When to use it

- **At the end of `/build`,** which runs it for you.
- **After a round of revisions,** once the new commits are on the branch.
- **Whenever you ask for a handover** of the branch that's checked out.

Claude may start it itself, because posting a comment is a record, not an approval.

## What you'll see

1. It checks the branch: not the default branch, named `<N>-<slug>`, its issue open, nothing uncommitted, and at least one commit of its own.
2. It runs every check from `.claude/workflow.md`. If one fails, it stops and posts nothing, because a handover says the work is ready.
3. It runs `fresh-eyes`, and fixes in-plan findings, one commit each.
4. It posts the handover on the issue without asking, and doesn't show the text in chat. Chat gets a short hand-back: the comment's link, the checks result, how many items are under **Needs you**, and anything missing from `.claude/workflow.md`. You review the comment after it's posted.

The handover has a fixed shape: **Branch**, **Covers** (the commit), **Compared with** (the base), what changed (a line per file), test results, the review's findings, and manual test steps.

### The review's findings

`fresh-eyes` reports Fix, Needs you and Dropped. The handover regroups them, fixing the Fix findings inside the plan and moving the rest to Needs you:

- **Needs you** comes first, because it's what you act on. Each has a ➡️ **Recommend** line.
- **Fixed:** in-plan findings Claude fixed, each as its own commit, with a ✅ line saying how and why, and the commit's short id. A separate commit lets you revert one fix on its own.
- **Dropped:** findings Claude judged wrong, each with why, so you can overrule the judgement.

A finding that needs new behaviour, outside the plan, isn't fixed. It goes under Needs you, recommending a new issue, so the plan you approved stays the plan that was built and the idea isn't lost.

## Gotchas

- **A later commit makes the handover stale.** `/ship` checks that the latest handover's **Covers** commit is the branch tip. If anything was committed since, run `/handover` again.
- **Run it again rather than editing a comment.** The latest `## Handover` on the issue is the one that counts.
- **Files are plain paths, not links.** The branch is local until `/ship`, so a GitHub link would be broken.
- **No Manual test setup in `workflow.md`:** it carries on, and says that `/setup-project` adds the section.

## Why it works this way

- **The comment names its commit,** so `/ship` can tell from any session whether the branch has moved since you reviewed it: [handovers on the issue](../../decisions/2026-10-15-215515-handovers-on-the-issue.md).
- **Needs you, Fixed and Dropped,** with each answer on its own line and an emoji to find it by: [clearer reports](../../decisions/2026-10-16-194758-clearer-reports.md).
- **The handover is on the issue only,** because the comment is the record `/ship` reads and a copy in chat is noise: [handover on the issue only](../../decisions/2026-10-22-205439-handover-on-the-issue-only.md).
