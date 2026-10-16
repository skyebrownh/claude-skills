# A review skill that only reports

Issue: #5

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
