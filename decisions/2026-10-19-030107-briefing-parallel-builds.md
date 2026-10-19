# Briefing parallel builds about shared files

Issue: #44

When `/build` runs several issues whose plans change the same file, it still builds them in parallel, but tells each subagent where its sibling is working there. Two issues built in parallel changed the same lines, and the second conflicted once the first merged. `2026-10-18-232724-fixing-conflicts-on-the-branch.md` fixes such conflicts after they happen. This makes them rarer in the first place, the same aim as `2026-10-16-193516-one-file-per-decision.md`.

- **Briefed, not stopped or sequenced.** Building one at a time throws away the parallel build for what's usually a few lines in README or the guide. A brief keeps the speed, and `/merge` still fixes any conflict that gets through.
- **Shown before the build, and again in the report.** Before, so Skye can stop it if she'd rather build one at a time. After, with where each subagent actually made its changes, so she sees what happened, not just what the plans intended.
- **Spots for new entries.** Git combines two changes only when at least one unchanged line sits between them. Two subagents told only to "stay apart" would both add their row at the end of the same table, so `/build` gives each issue its own spot.
- **Worked out from the plans, not the code.** Nothing is built yet when the subagents start, so the plans' `### Files` lists are all there is. The section comes from each entry's wording. When it isn't clear, the subagent gets the sibling's whole entry to stay away from, rather than the build stopping.

Left out: overlap checks in `/plan-issue` and `/draft-issue`, blocked-by links for shared files, and a "section" field in the plan format, which could be a new issue if working out sections from an entry's wording proves unreliable.
