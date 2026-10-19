# Handovers live on the issue

Issue: #8

Replaced in part by: [2026-10-16-194758-clearer-reports](2026-10-16-194758-clearer-reports.md): Act on findings became Fix findings, and the handover lists findings under Needs you, Fixed and Dropped, and Covers names only the short sha, not "the branch tip".

`/handover` (#8) records each handover as a `## Handover` comment on the issue, naming the commit it covers (the branch tip). It's the first child of #18, which lets Claude commit on feature branches during the build.

- **The handover names its commit,** so `/ship` (#20) can check, from any session, that the branch hasn't moved since Skye reviewed it. Before, the handover lived in the conversation, so only the session that built the work could ship it.
- **It covers committed work only,** and stops if anything is uncommitted or untracked: what Skye reviews must be exactly what gets pushed.
- **No suggested commit message any more:** commits are made during the build, and the squash merge takes the issue's title.
- **Claude may start it,** unlike `/ship` and `/merge`: posting a comment on the issue is a record, not an approval, and `/build` (#19) calls it at the end of every build.
- **Fresh-eyes findings:** Act on findings within the approved plan are fixed before the handover, one commit each, so Skye can see each fix and revert it alone. Everything else is listed untouched, so she can overrule the judgement. This is how `fresh-eyes`, which never changes a file, fits a step that does.
- **Files are plain paths in the comment,** not links, because the branch stays local until `/ship`, so a GitHub link would be broken.
- **A `Manual test setup` section in `workflow.md`** holds what Skye does before trying a change by hand, so each handover's steps don't have to work it out again. Projects set up earlier get it through migration 3 (#20).
