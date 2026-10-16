# Workflow facts

<!--
Facts about this project that Skye's personal skills (/ship, /merge) read,
so the skills themselves stay the same in every project. Written by
/setup-project; edit by hand any time. Keep each section's heading exactly as
it is: the skills find facts by heading.
-->

## Process version

<!-- Which version of Skye's process this project is set up for. Change it only through /setup-project, which applies the migrations that bring a project up to date. -->

3

## Default branch

`main`

## Checks before committing

<!-- Every command must pass before /ship commits. One per line. -->

```sh
bash tests/test_install.sh
```

## Manual test setup

<!-- What Skye does before trying a change by hand, and anything to undo afterwards. /handover starts its manual test steps from here. -->

- Installed skills run from whichever branch is checked out here. To try a branch, switch to it here (`git switch <branch>`), and run `./install.sh <name>` for any skill it adds.
- Afterwards, switch back to `main` (`git switch main`), so other projects run the reviewed version.

## Pull requests

- Template: `.github/pull_request_template.md`
- Copy the issue's milestone and labels onto the PR: yes (the repo has no milestones, so in practice labels only)

## Merging

- Single-issue PR: squash, subject `<issue title> (#<PR>)`
- Parent PR: rebase
- Merging deploys: no
- Where it deploys: nowhere. But installed skills are symlinks into this folder, so once `/merge` updates `main` here, every project runs the merged version.
