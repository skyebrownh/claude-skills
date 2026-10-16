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

## Listing them

```sh
ls decisions/
```

lists them oldest first, because the names start with the timestamp.
