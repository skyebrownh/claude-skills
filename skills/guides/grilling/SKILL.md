---
name: grilling
description: How to interview Skye in rounds of numbered questions with recommended answers until every decision is settled. Use when drafting an issue or plan with her, when a skill says to interview her, or when she asks to be grilled on an idea.
---

# Grilling: interview Skye until nothing is left open

The goal is a shared understanding, with every decision made by Skye and every fact found by you. Put each step below on the task list.

## 1. Map the decisions as a tree

List the decisions the work needs. Some depend on others (where a file goes depends on whether it's needed at all), so track them as a **tree**: each decision branches into the decisions that hang off it.

The **frontier** is every open decision whose parents are already settled: the questions you can ask now without guessing at answers you haven't heard yet.

This step is done when every decision you can see is on the tree, and you know which ones are on the frontier.

## 2. Look up facts in subagents

A **fact** is anything you could find by looking (the test command, whether a file exists, how recent PRs were merged). Look facts up yourself, because asking Skye for something the repo already shows wastes her time. A **decision** is a choice only Skye can make, so it goes to her.

For each frontier question that needs a fact, start a read-only **Explore** subagent on the `haiku` model to find it, because a lookup only reports what it found and you check that against the question. Subagents run alongside you, so the interview keeps moving. A running lookup counts as an open parent: only the questions that depend on it wait for it, and the rest are asked now.

This step is done when every fact the frontier needs has been found, or has a lookup running.

## 3. Ask the whole frontier

Ask every frontier question in one round, however many there are. Holding questions back only adds rounds. For each question:

- **Number it,** so Skye can answer by number.
- **Give your recommended answer and its source** (a file, a command, a convention, or your reasoning).
- **Word it so "yes" accepts the recommendation,** so agreeing costs her one word.

For example:

> 1. **Tests:** `uv run python manage.py test` (from README). Use that?
> 2. **Merge style:** squash, since recent merges each add one commit ending `(#N)`. Keep squashing?

A question that depends on another still open, in this round or in a running lookup, waits for a later round, because its answer could change. Skye can reply "all yes", or with a number and a correction.

This step is done when the round is sent and Skye has answered it.

## 4. Update the tree and repeat

Record each answer. A settled decision can unblock new questions, close a branch that no longer applies, or raise a decision nobody had seen. Recompute the frontier, collect any lookups that have reported, and go back to step 3.

This step is done when the frontier is empty: every branch visited and nothing silently assumed.

## 5. Confirm and summarise

Ask Skye to confirm that nothing is left open. If she raises something, add it to the tree and go back to step 3. Once she confirms, summarise the decisions, grouped as the tree groups them, with each one's answer.

This step is done when Skye has confirmed nothing is left open and seen the summary.
