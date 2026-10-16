# Parent and child issues replace `/ship-set`

Issue: #3

heritage-media-availability's `/ship-set` shipped a branch for several issues. GitHub now records parent/child (sub-issue) and blocked-by links as data, so `/ship` reads those instead (#3). A parent's `**Ships as:**` line decides how its children become PRs:

- **one PR per child** (the default): each child is a vertical slice, a thin piece that works end to end on its own, with its own branch and PR. The idea comes from Matt Pocock's skills ([mattpocock/skills](https://github.com/mattpocock/skills), MIT). The child's PR says `Part of #P`.
- **one PR:** `/ship <child#>` commits each child on the parent's branch, and a final `/ship` opens one PR that closes the parent and every child. `/merge` uses the project's **Parent PR** style (rebase here, so each child's commit stays on `main`).

Choices worth remembering:

- **No `Ships as:` line means stop.** How the work ships is Skye's call, not a default to guess.
- **A child can have more than one commit.** A fix to an earlier child found while working on a later one becomes `<child title> (follow-up)`, rather than a new child issue or an amended commit (history is never rewritten).
- **Blocked children stop `/ship`,** except that on a parent's branch a sibling already committed there counts as done: it can't close until the shared PR merges.
- The `workflow.md` wording changed from "Multi-issue PR" to "Parent PR".
- Handovers come from the conversation for now. Once `/handover` exists (#8), `/ship` reads only the issue's latest `## Handover` comment, so it never depends on which session runs it.
