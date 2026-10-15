---
name: tdd
description: How Skye builds code test-first, in thin red-green slices that test behaviour through public paths. Use when building a feature from an approved plan, when fixing a bug, or when writing or reviewing tests.
---

# Test-driven development

Build in a red, green, refactor loop, one thin slice at a time, so every piece of behaviour is proven by a test that was seen to fail first. Put each step below on the task list.

What makes a test worth keeping is below the steps, and [good-tests.md](good-tests.md) has short good and bad examples in Python and JavaScript.

## 1. List the behaviours to test

The behaviours come from the issue's approved plan, so they need no separate approval: Skye already approved what the work should do. Write them down as a short list, each one phrased as something a user or caller can observe ("a closed month rejects new bookings").

- **A bug** is one behaviour: the correct behaviour the bug breaks.
- **A test the plan didn't foresee** is fine when it tests planned behaviour (an edge case, an error path). Note it for the handover.
- **A new behaviour** the plan doesn't cover is out of scope. Suggest it as a new issue, and leave it unbuilt.

This step is done when every behaviour in the plan is on the list.

## 2. Red: write one failing test

Pick the next behaviour and write **one** test for it, through a public path (see "Where tests go"). Run it and watch it fail, for the reason you expect. A test that passes straight away, or fails for another reason (a typo, a missing import), proves nothing yet.

For a bug, this test reproduces the bug, so it fails because of the bug itself.

This step is done when the new test fails, and its failure message shows the missing behaviour.

## 3. Green: write the least code that passes

Write only enough code to make that test pass, and leave the next behaviour for its own slice. Code written ahead of a test is untested, and it guesses at needs the next test may change. Run the tests.

This step is done when the new test and every earlier test pass.

## 4. Refactor while green

With every test passing, tidy what you just wrote: clearer names, a repeated piece pulled out, a simpler shape. Change structure only, and re-run the tests after each change, because green is what tells you behaviour is unchanged. Skip this step when there's nothing worth tidying.

This step is done when the tests pass again after the last change.

Then go back to step 2 with the next behaviour, until the list from step 1 is done.

## 5. Run the project's checks

Read `.claude/workflow.md` and run every command under **Checks before committing**, because those are the checks `/ship` runs before committing. If the file or the section is missing, say so and suggest `/setup-project`.

This step is done when every check passes, and the handover lists the test results and any tests the plan didn't foresee.

## Where tests go

Test behaviour through the app's **public paths**: views and URLs, commands, and public functions. These are what users and other code rely on, so a test there survives any rewrite of the inside. A test is in the right place when you could rewrite the code behind it and the test would still pass.

## What to mock

Mock only what you don't control, or what changes between runs:

- **External services** (payment, email, third-party APIs), so tests don't send real requests.
- **Time and randomness,** so results are the same on every run.

Use a **test database** rather than a mocked one. Frameworks like Django give each test run its own database, and a real database catches mistakes a mock would happily accept. Your own modules and classes run for real, because mocking them ties the test to how the code is built.

## Anti-patterns

- **Implementation-coupled:** the test mocks your own code, calls private functions, or checks a side channel (querying the database instead of using the public path). The tell: it breaks when you refactor, though behaviour hasn't changed.
- **Tautological:** the expected value is worked out the same way the code works it out, so the test passes by construction and can never disagree with the code. Take expected values from an independent source: a known literal, a worked example, the spec.
- **Horizontal slicing:** writing all the tests first, then all the code. Those tests check behaviour you imagined before learning anything from the code. Work in **vertical slices** instead: each test is a tracer bullet, shaped by what the last slice taught you.
