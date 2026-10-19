# Decisions

Choices about how these skills work, one file each, with the reason. Ideas borrowed from other people's skills are credited here.

## Naming a file

`YYYY-MM-DD-HHMMSS-short-slug.md`, for example `2026-10-15-130818-start-a-personal-skills-repo.md`:

- **The timestamp** is when the decision was made, in 24-hour local time to the second. Get it with `date +%Y-%m-%d-%H%M%S`. It only orders the files: seconds rather than minutes, so decisions written in the same minute on branches built in parallel still sort in the order they were made.
- **The slug** is 2 to 5 lowercase words saying what was decided. It keeps names unique, so two branches never write the same file.

The entries moved here from the old single file are timed from the commit that added each one. Where one commit added several, each later one is a second after the one before, so they keep their old order.

## Inside a file

```markdown
# <title>

Issue: #<N>

<the decision and why>
```

The `Issue:` line names the issue the decision came from, and is left out where there wasn't one. Link to another decision by its file name.

## When a later decision replaces one

An older decision stays as written, because it records what was decided at the time. When a later decision replaces part of it, the older file gets one marker line, so a reader of `decisions/` alone doesn't take the old rule as current:

```markdown
# <title>

Issue: #<N>

Replaced in part by: [<newer file>](<newer file>.md): <what changed, in a clause>
```

For example, `2026-10-15-172511-parent-and-child-issues.md` has:

```markdown
Replaced in part by: [2026-10-16-001711-shipping-committed-branches](2026-10-16-001711-shipping-committed-branches.md): a fix to a folded child is a new child issue, not a `(follow-up)` commit.
```

- **It goes under the `Issue:` line,** or under the title if there's no `Issue:` line, after a blank line so it shows as its own paragraph.
- **One line per newer file,** when more than one decision replaced parts of it.
- **`Replaced by:`** in place of `Replaced in part by:`, only when the whole decision no longer holds.
- **The marker is the only edit** made to an older decision.
- **The newer decision's own branch adds it,** in the same change that writes the newer file.

## Listing them

```sh
ls decisions/
```

lists them oldest first, because the names start with the timestamp.
