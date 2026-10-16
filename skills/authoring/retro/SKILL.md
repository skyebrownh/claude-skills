---
name: retro
description: Look back over the current session for Skye's corrections and steps that went wrong, and turn the ones that will happen again into fixes at the highest level (a check or test, then a skill change, then a CLAUDE.md line), handed over as /draft-issue lines. Use only when Skye types /retro.
disable-model-invocation: true
argument-hint: "(no arguments; reads the current session)"
---

# Look back over this session

Skye typed `/retro`. **That is her approval to read this session and report; it changes nothing.** No skill, CLAUDE.md or issue is edited or created: findings become issues only through `/draft-issue`, which she types herself.

It reads the current session only, never another one. Check everything first, and stop at the first problem, saying what's wrong and what to do. Put each step below on the task list.

This skill needs no `.claude/workflow.md`, so it works in any project.

## The ladder

Every finding is fixed at the highest rung that would have prevented it, because each rung down relies more on Claude remembering:

1. **An automated check or test:** a script, hook, lint rule or test that fails when the mistake happens. It works whether or not anyone remembers it.
2. **A skill change:** a step, stop condition or completion criterion in the skill that was running.
3. **A CLAUDE.md line:** for a judgement call no check or step can make. The global `CLAUDE.md` for every project, or the project's own.

## 0. Find this session's transcript

Claude Code saves each session as a `.jsonl` file under `~/.claude/projects/`. The current one is the newest that holds the `/retro` Skye just typed:

```sh
grep -l '<command-name>/retro</command-name>' ~/.claude/projects/*/*.jsonl | xargs ls -t | head -1
```

Search every project folder, not just this folder's, because a session that moved folders stays filed under the one it started in. And match the command rather than taking the newest file, because another session may have written more recently.

Show Skye the file's first message from her (`jq -r 'select(.type == "user") | .message.content | strings' <file> | head -1`, cut to a line) and when it started (the first line's `timestamp`), and wait for her to confirm it's this session.

**No file matches:** stop and say so, rather than reading another session.

This step is done when Skye has confirmed the transcript.

## 1. Trim it

```sh
jq -r -f <this skill's folder>/trim-transcript.jq <file> > <scratchpad>/retro-transcript.txt
```

[trim-transcript.jq](trim-transcript.jq) keeps Skye's messages, Claude's text, each tool call in short, and failed tool results, each line starting with its line number in the `.jsonl`. A transcript can run to megabytes of tool output that says nothing about corrections. The file on disk still holds everything from before any compaction, so trimming loses no conversation.

This step is done when the trimmed file exists and isn't empty.

## 2. Read it in a subagent

Start one subagent with `subagent_type: Explore`, so the session's text stays out of this conversation. Give it only the paths and this brief, with no summary of the session, so it reads what happened rather than what this conversation remembers:

> Read <trimmed file> in full. It's a Claude Code session: lines marked SKYE are the user, CLAUDE is the assistant, TOOL lines are its tool calls, and TOOL FAILED lines are refused or failed calls. Also read every file in <the transcript's folder>/memory/, if it exists: notes Claude saved about earlier corrections. List (a) each time Skye corrected Claude, pushed back, or asked for something to be redone, and (b) each step that went wrong without her saying so (a failed command retried blindly, a rule broken, a step skipped). For each: the line numbers, a short quote, what went wrong, whether it happened more than once in this session, and whether a memory note shows it happened before. Read only: change no files. Under 600 words.

This step is done when the report is back.

## 3. Judge each finding

Check each one against the trimmed transcript before keeping it: the reader works from text alone and can misread a joke or a change of mind as a correction.

- **A finding is real** when it happened twice in this session; or once here and once before (a memory note, or an earlier issue: `gh issue list --state all --search "<key words>"`); or a skill or CLAUDE.md instruction caused it, because a wrong or missing instruction will cause it again.
- **A one-off** is a slip with no cause in the instructions. Drop it, with one line on why. One-offs aren't findings.
- **Already covered:** a rule or skill step that should have prevented it exists and was broken. Name it, and move the fix one rung up the ladder from where that rule sits, because the rung it's on didn't hold.
- **The fix:** the highest rung that would have prevented it, with what to add, and why a higher rung won't work.
- **The repo:**
  - a skill or the global `CLAUDE.md` goes to the skills repo, found by following this skill's link (`readlink ~/.claude/skills/retro`) back to its repo;
  - a project's tests, checks or CLAUDE.md go to that project.

This step is done when every finding is real (with its rung, fix and repo) or dropped with a reason.

## 4. Report

For each real finding:

- what happened, with the transcript's quotes and line numbers;
- how often, and any earlier record;
- the rule it broke, if one exists;
- the rung, the fix, and the repo.

Then the dropped one-offs, one line each. Skye decides which findings to keep.

This step is done when Skye has kept or turned down every finding.

## 5. Hand over

For each repo with a kept finding, write one `/draft-issue` line holding those findings, one idea each, with each one's rung and fix, and say which folder to type it in. `/draft-issue` is a skill only Skye starts, so this skill can't run it; typing the line is her approval to draft, and it checks for duplicates first.

This step is done when Skye has a line for every repo with a kept finding, or knows none were kept. Then stop.
