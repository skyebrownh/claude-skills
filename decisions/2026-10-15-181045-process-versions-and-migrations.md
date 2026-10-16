# Process versions and migrations keep projects in step

Issue: #14

Changing this repo can leave projects set up earlier behind: after #3, heritage-media-availability's `workflow.md` still said `Multi-issue PR:`. Each project now records a **Process version**, and `skills/workflow/setup-project/migrations.md` lists numbered migrations, each saying what to change in a project and why (#14). It's the same idea as database migrations: apply every one above the project's version, in order, then record the new version.

Choices worth remembering:

- **The current version is the newest heading in `migrations.md`,** so the number lives in one place. A project with no version counts as version 1, the process before #14.
- **`/ship` and `/merge` stop when a project is behind,** rather than running on facts that may no longer mean what they expect. They read `migrations.md` from `/setup-project`'s folder, because skills only Skye starts can't call each other.
- **Each change names the text it expects,** and a mismatch stops and asks instead of overwriting, because it likely means the project was customised.
- **`/setup-project` applies the migrations,** rather than a separate `/align` skill: it already writes `workflow.md`, and keeping one owner for that file avoids two skills disagreeing about it.
