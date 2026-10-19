# `grilling`

An interview in rounds of numbered questions, each with a recommended answer, until every decision the work needs is yours and settled.

For the exact steps, see its [SKILL.md](../../skills/guides/grilling/SKILL.md).

## When to use it

- Claude starts it from inside other skills: `/new-project`, `/setup-project`, `/draft-issue` and `/plan-issue` all grill you before they write anything.
- You can ask for it by name, for example "grill me on this idea", whenever you want to think something through before building it.

## What you'll see

- **Rounds of numbered questions.** Each round asks every question that can be asked right now, however many there are. Answer by number.
- **A recommended answer on each question,** with where it came from (a file, a command, a convention, or Claude's reasoning). Each question is worded so that "yes" accepts the recommendation.
- **Short replies work.** "All yes" accepts every recommendation. "Yes, except 3: use pytest" accepts the rest and corrects one.
- **New questions in later rounds.** Some questions only make sense once an earlier one is answered, so they wait for the next round.
- **A last check.** When nothing seems open, Claude asks you to confirm that nothing is left, then shows a summary of every decision.

## Decisions it asks you about

Only decisions: choices that are yours to make. Facts, things Claude could find by looking (the test command, whether a file exists, how past PRs were merged), it looks up itself in subagents instead of asking you.

## Gotchas

- **Correct a recommendation you disagree with.** A "yes" is a real answer, and it ends up in whatever the skill writes next: an issue, a plan, a spec or `workflow.md`.
- **Raise anything it missed at the last check.** Saying so adds it to the list and starts another round; the summary only comes once you confirm nothing is left.
- **A round can be long.** That is on purpose: holding questions back would only add more rounds.

## Why it works this way

These choices are recorded in [the grilling and tdd decision](../../decisions/2026-10-15-185652-grilling-and-tdd.md), which adapts Matt Pocock's `grilling`. Some of the reasons are in its SKILL.md:

- **Questions form a tree.** Some decisions hang off others, so a round only asks the ones whose parents are settled. That way no question guesses at an answer you haven't given yet.
- **No limit on questions per round,** because holding them back only adds rounds. This replaced an older "at most four questions" rule in `/setup-project`.
- **Facts are looked up, not asked,** because asking you for something the repo already shows wastes your time. The lookups run on a cheaper model, as [this decision](../../decisions/2026-10-19-154955-cheaper-lookup-subagents.md) explains.
- **Each recommendation names its source,** so you can judge how far to trust it.
- **It ends only when you confirm,** so nothing is silently assumed.
