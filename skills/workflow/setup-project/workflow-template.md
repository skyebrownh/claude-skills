# Workflow facts

<!--
Facts about this project that Skye's personal skills (/handover, /ship, /merge) read,
so the skills themselves stay the same in every project. Written by
/setup-project; edit by hand any time. Keep each section's heading exactly as
it is: the skills find facts by heading.
-->

## Process version

<!-- Which version of Skye's process this project is set up for. Change it only through /setup-project, which applies the migrations that bring a project up to date. -->

<current version: the newest heading in setup-project's migrations.md>

## Default branch

`main`

## Checks before committing

<!-- Every command must pass before each commit during the build, and again when /ship runs. One per line. -->

```sh
<test command, e.g. uv run --env-file .env python manage.py test>
<any other check, e.g. a production-readiness or lint command>
```

## Manual test setup

<!-- What Skye does before trying a change by hand, and anything to undo afterwards. /handover starts its manual test steps from here. -->

- <e.g. start the dev server: uv run --env-file .env python manage.py runserver>
- <e.g. log in as the seeded admin user from the fixtures>

## Pull requests

- Template: `<path, e.g. .github/pull_request_template.md, or "none">`
- Copy the issue's milestone and labels onto the PR: <yes / no>

## Merging

- Single-issue PR: <squash / rebase / merge commit>, subject `<issue title> (#<PR>)`
- Parent PR: <rebase / squash / merge commit / not used>
- Merging deploys: <yes / no>
- Where it deploys: <e.g. Railway production and staging, from `main`; or "nowhere">

## After a deploy, check

<!-- What Skye looks at once a merge has deployed. /merge lists these; it never checks them itself. Delete the section if nothing deploys. -->

- <e.g. the new deployment succeeded in every environment>
- <e.g. the health check passed in the deploy log>
- <e.g. if the PR has migrations, the migrate step succeeded>

## Releases

<!-- Optional. When /merge should suggest a release (it never creates one). Delete the section if this project doesn't do releases. -->

- <e.g. when a milestone has no open issues left>
