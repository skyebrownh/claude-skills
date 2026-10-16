# CLAUDE.md

<!--
Written by /new-project in its phase 6. This file is for Claude: the
project's stack, architecture, conventions and commands. Skye's process
(issues, plans, builds, shipping) lives in her skills, and what the app does
lives in SPEC.md, so neither is repeated here. Keep it short, and update it
when a convention or command changes. Remove every guidance comment once its
section is filled in.
-->

## <Project name>

<One or two sentences: what the project is and who it's for.> **SPEC.md is the source of truth** for what it does and why. **GitHub issues** hold the work. Read SPEC.md and the issue before starting any task, and cite requirement IDs and the issue number in plans and summaries.

@SPEC.md

## Stack (do not change without asking)

<!-- Each choice from SPEC.md's Technical approach, as Claude needs to apply it: versions, package manager, approved packages. Anything else needs Skye's approval first. -->

- <language and version>
- <framework>
- <database>
- <hosting>
- <test runner>
- Approved packages: <list>. Anything else needs approval first.

## Architecture

<!-- How the code is laid out once it exists: the main modules and what each owns. Filled in by the first issues that add code. -->

<Added by the first issue that adds code.>

## Conventions

<!-- Project-specific rules Claude must follow: naming, comments citing requirement IDs, design rules, anything settled while building. -->

- Code comments cite the requirement ID they implement (e.g. `# <XX-3>: <why>`).

## Commands

<!-- Exact commands, each with what it's for. -->

- Run locally: `<command>`
- Run tests: `<command>`

Project facts for Skye's personal skills (checks, merge style, whether merging deploys) are in `.claude/workflow.md`; update it with `/setup-project`.
