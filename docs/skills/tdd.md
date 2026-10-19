# `tdd`

How Claude builds code test-first: one thin slice at a time, each proven by a test that was seen to fail before the code was written.

For the exact steps, see its [SKILL.md](../../skills/guides/tdd/SKILL.md). Short good and bad test examples, in Python and JavaScript, are in [good-tests.md](../../skills/guides/tdd/good-tests.md).

## When to use it

- `/build` follows it to build an issue's approved plan.
- Claude also reaches for it to fix a bug, and when writing or reviewing tests.

## What you'll see

- **A list of behaviours,** taken from the plan's Tests section, each phrased as something a user or caller can see ("a closed month rejects new bookings").
- **Red, green, refactor, per behaviour.** Claude writes one test, runs it and watches it fail (red). It writes just enough code to pass (green), then tidies while every test still passes (refactor). Then the next behaviour.
- **The project's checks at the end,** the commands in `.claude/workflow.md` under "Checks before committing".
- **In the handover:** the test results, and any test the plan didn't foresee.

## Decisions it asks you about

None while it runs. You decided what the work should do when you approved the plan, so the behaviours to test come from there. A new behaviour the plan doesn't cover isn't built: it's suggested as a new issue.

## Gotchas

- **A test must fail first, for the right reason.** A test that passes straight away, or fails on a typo, proves nothing yet.
- **A bug fix starts with a test that reproduces the bug,** so you know the fix is what made it pass.
- **Tests go through public paths:** views and URLs, commands and public functions. A good test would still pass if the code behind it were rewritten.
- **Only what you don't control is mocked:** external services (payment, email, other APIs), time and randomness. Your own code and a test database run for real, because a mock happily accepts mistakes the real thing would catch.
- **Three kinds of test to avoid,** each explained in SKILL.md: tests coupled to how the code is built, tautological tests that work out the answer the way the code does, and writing all the tests before any code.
- **No checks set up?** If `.claude/workflow.md` is missing, Claude says so and suggests `/setup-project`.

## Why it works this way

The reasons are in [the grilling and tdd decision](../../decisions/2026-10-15-185652-grilling-and-tdd.md), including what was borrowed and what changed:

- **The tests come from the approved plan,** rather than a second approval, because you already approved what the work should do.
- **Refactoring happens inside the loop, while green,** because tidying is cheapest while the code is fresh, and the passing tests prove nothing changed.
- **Mocks are limited** to external services, time and randomness, with a real test database preferred to a mocked one.
