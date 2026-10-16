# One file per decision

Issue: #33

The old single decisions file, which every change added to, split into a file per decision in `decisions/`. Branches built in parallel each added an entry at the bottom of the same file, so they conflicted when the second one landed.

- **Named by timestamp, then slug** (`YYYY-MM-DD-HHMMSS-short-slug.md`), so `ls decisions/` lists them in the order they were made. The slug keeps names unique, so branches never write the same file; the timestamp only orders them.
- **Seconds, not minutes,** so decisions written in the same minute on parallel branches still sort in order. Git records commit times to the second, so the moved entries got seconds too.
- **Not ordered by issue number:** an issue's number is set when it's drafted, not when its decision is made.
- **Local time,** for the moved entries and new ones alike, from `date +%Y-%m-%d-%H%M%S`.
- **The moved entries are timed from the commit that added each one.** Where one commit added several, each later one is a second after the one before, so they keep their old order.
- **An `Issue:` line** names the issue a decision came from, rather than a running index, which would be one more shared file for branches to conflict over.
- **Split by a one-off script,** with a check that joined the bodies back together and compared them with the old file, so no text was lost across 18 entries. The only change to their text is that "see the next entry" became a link.

Left out: the `## Decisions` section of SPEC.md in other projects, which would need a process migration.
