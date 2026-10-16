# <Project name>: spec

<date> · <author>

<!--
What the project does and why: the source of truth that issues, plans and
reviews cite. Written by /new-project from the grilling in its phase 2, and
kept current by hand: a change to what the app does edits the requirement
here in the same PR. Build status lives in GitHub issues, never here.
Remove every guidance comment once its section is filled in.
-->

## Problem statement

<!-- The problem, from the users' point of view: who has it, what they do today, and why that hurts. No solution yet. -->

## Overview

<!-- The solution from the users' point of view: one line (it becomes the GitHub repo's description), then a short paragraph on what they'll do with it and what changes for them. -->

**In one line:** <what the project does, for whom>

**Today:** <how it's done now>

**Goal:** <what the project makes possible>

**Success for v1:** <how we'll know v1 worked, ideally something you can count>

## Users and roles

<!-- One row per role. Say how each gets in, since login is often the biggest design choice. -->

| Role | Who | How they get in | What they can do |
| --- | --- | --- | --- |
| <role> | <who, how many, how comfortable with tech> | <link, login, …> | <what they can do> |

## Scope

### In v1

<!-- What v1 must do, as a short list. /new-project's phase 9 turns this list into the first issues. -->

- <item>

### Later

<!-- Wanted, but not in v1. -->

- <item>

### Non-goals

<!-- What the project will never do, with the reason, so it doesn't creep in. -->

- <item>

## Functional requirements

<!--
Each requirement has an ID: a short prefix per area plus a number (e.g. TF-3
for the third team-form requirement). Issues name the IDs they deliver, and
code comments cite them. Never reuse a number: a dropped requirement stays,
marked "(removed)".
-->

### <Area>

| ID | Requirement |
| --- | --- |
| <XX-1> | <one behaviour someone can check> |

## Key user flows

<!-- The main journeys, step by step, one subsection each. -->

### <Flow>

1. <step>

## Business rules

<!-- Rules that must hold on the server (or wherever the data lives), not just in the interface. -->

- **<rule>.** <detail and reason>

## Data model

<!-- One table per thing stored, with each field's type and notes. Say what the model leaves room for later. -->

### <table>

| Field | Type | Notes |
| --- | --- | --- |
| id | integer | Primary key |

## Non-functional requirements

<!-- The bar for devices, accessibility, speed, security, cost and backups. -->

- **<quality>.** <the bar, so it can be checked>

## Technical approach

<!--
The stack and hosting chosen in /new-project's phase 3, with the reason and
the alternative that lost. Describe modules and interfaces, never file paths
or code, so this section doesn't go stale as the code moves.
-->

| Layer | Choice | Why |
| --- | --- | --- |
| <layer> | <choice> | <reason> |

**Alternative:** <the option not chosen, and why>

## Testing approach

<!--
What a good test is here, what gets tested (and what doesn't), and examples
to follow once they exist. /plan-issue and tdd lean on this section.
-->

- **Good tests:** <e.g. test behaviour through public paths, not internals>
- **What gets tested:** <e.g. every requirement ID has a test; business rules are tested on the server>
- **Not tested automatically:** <e.g. look and feel, checked by hand>
- **Examples to follow:** <filled in once the first tests exist>

## Timeline and open questions

<!-- Milestones with dates. /new-project creates a GitHub milestone for each. -->

| Milestone | Dates | Focus |
| --- | --- | --- |
| <name> | <dates> | <focus> |

### Open questions

- <question, or "None">

## Decisions

<!-- Choices that aren't captured in a requirement, newest last, with the date. A decision that changes a requirement edits that requirement instead. -->

- <date>: <decision and reason>
