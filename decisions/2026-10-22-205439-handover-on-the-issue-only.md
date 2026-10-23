# Handover on the issue only

Issue: #56

Replaces part of: [2026-10-16-194758-clearer-reports.md](2026-10-16-194758-clearer-reports.md): #32's criterion "Chat shows the same text that's posted on the issue" no longer holds.

`/handover` posts the `## Handover` comment on the issue and no longer shows its text in chat. Chat gets one short paragraph instead: the comment's link, the checks result in one line, the number of items under **Needs you**, and anything missing from the project's workflow facts.

- **The comment is the record.** `/ship` reads it, and Skye reviews it on the issue. A second copy in chat added length without adding anything she could act on.
- **Plain paths stay.** The branch is local until `/ship`, so a GitHub link to a file would be broken. That reason stands without the "same text in chat" one.
- **Fresh-eyes still reports in chat** when run on its own, and still uses only headings, bold and lists, because chat shows HTML as raw tags and a handover copies its findings into the comment.

Left out: a chat-only handover for a branch with no issue. It would touch `/ship`, `/build`, `/whats-next` and the "proof of review" decision.
