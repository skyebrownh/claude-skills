---
name: new-project
description: Set up a brand-new project from an idea, in its own folder (spec, CLAUDE.md and README, git and GitHub, workflow.md), then hand the first issues to /draft-issue. Use only when Skye types /new-project.
disable-model-invocation: true
argument-hint: "<the idea, in a sentence or two>"
---

# Start a new project

Skye typed `/new-project $ARGUMENTS`. **That is her approval to start, not to create the repo or push.** Every phase ends on her approval, and nothing is written, created on GitHub, committed or pushed until she approves that phase's output in chat.

It runs in the new project's folder, which is usually empty. Check everything first, and stop at the first problem, saying what's wrong and what to do. Put each phase below on the task list, and keep a phase there with its reason if it's skipped.

This skill needs no `.claude/workflow.md`: it writes one in phase 8, through `/setup-project`.

## 0. Check, and find where the project is

1. Run `gh auth status`. **It fails:** stop, and say to run `gh auth login`, because phase 7 creates the repo with `gh`.
2. Run `git rev-parse --show-toplevel`. **It prints a folder other than this one:** stop. This folder is inside another repo, so a new repo here would be nested in it. Say to make the project's folder somewhere else (such as `~/Developer/<name>`) and start there.
3. Work out which phases are already done, from what exists:

   | What exists | Start at |
   | --- | --- |
   | No `SPEC.md` | Phase 1 |
   | `SPEC.md`, but not both `CLAUDE.md` and `README.md` | Phase 6 (offer to run phase 5 first, if the spec hasn't been challenged) |
   | Both, but no `origin` remote (`git remote get-url origin`) | Phase 7 |
   | A remote, but no `.claude/workflow.md` | Phase 8 |
   | `.claude/workflow.md`, but nothing pushed (`git ls-remote origin main` prints nothing) | Phase 8, from the first commit |
   | A pushed first commit | Phase 9 |

   **Something is done already:** say what you found, and offer to carry on from that phase. A session can end between any two phases, so a fresh session picks the work up here.
4. **Other files are in the folder** (Skye's notes, sketches): list them, and read any that describe the idea, as input to phase 1.

This step is done when `gh` works, the folder isn't inside another repo, and Skye has agreed which phase to start at.

## 1. Restate the idea

Say the idea back in your own words: the problem, who has it, and what the project would do about it. Skye corrects it. Saying it back catches a misunderstanding before it's built into the spec. From pstack's `in-your-own-words`.

This phase is done when Skye agrees the restatement is right.

## 2. Grill

Follow `grilling`, looking facts up in subagents as it says, so research stays out of this conversation. Cover what the spec needs:

- the problem, the users, and what success looks like;
- scope: what's in v1, what's later, and the non-goals;
- the main user flows, the business rules, and the data;
- the stack, hosting and running cost (the big choices are settled in phase 3);
- the timeline.

User stories ("as a volunteer, I want…") can help a question along, but they don't become a spec section.

This phase is done when `grilling` ends with Skye confirming nothing is left open.

## 3. Compare the big choices

For each choice that is costly to change later (the stack, hosting, anything grilling marked as big): set two real options side by side, with what each costs, what it makes easy, and what it makes hard, and recommend one with the reason. Research them in subagents. From pstack's `architect`.

**A choice that needs a prototype** to settle (how a screen feels, whether a library fits): say so and recommend one, and leave it unbuilt. It becomes an issue for `/plan-issue` to plan later.

This phase is done when Skye has picked an option for every big choice.

## 4. Write SPEC.md

Fill in [spec-template.md](spec-template.md) from phases 1 to 3, removing its guidance comments. Two rules from the template matter most:

- **Technical approach** names modules and interfaces, never file paths or code, so it doesn't go stale as the code moves.
- **Testing approach** says what a good test is here, and what gets tested, because `/plan-issue` and `tdd` lean on it.

Show the complete spec, then write `SPEC.md` at the project root only after Skye approves it.

This phase is done when `SPEC.md` is written as approved. The spec is the handoff point: if this session is getting long, suggest carrying on in a fresh one.

## 5. Challenge the spec

Follow `fresh-eyes` with the path `SPEC.md`: a reader with none of this conversation reads it cold for gaps, contradictions, unstated assumptions and untestable requirements. Show its findings. Skye decides which to fix; show each fix's before and after, and apply the fixes she approves.

This phase is done when every finding is fixed or set aside by Skye.

## 6. Write CLAUDE.md and README.md

Fill in [claude-md-template.md](claude-md-template.md) and [readme-template.md](readme-template.md) from SPEC.md, removing their guidance comments:

- **CLAUDE.md is for Claude:** stack, architecture, conventions, and the commands Claude runs. Skye's process lives in her skills, so it isn't repeated there.
- **README.md is for people:** what the project is, and how to install, run and test it.

Only the test command appears in both, because each reader looks in their own file. A section that needs code that doesn't exist yet says "Added by the first issue that adds code." Show both files, then write them only after Skye approves.

This phase is done when both files are written as approved.

## 7. Set up git and GitHub

Show everything this phase will do, with the real values filled in, and run it only after Skye approves:

1. `git init -b main`.
2. `.gitignore`, built from [gitignore-starters.md](gitignore-starters.md): the Common block, plus the block for each language in the stack.
3. `.github/`, copied from this skill's [github/](github/) folder: the feature, bug and parent issue templates, `config.yml`, and the PR template.
4. The repo, named after this folder, private, with SPEC.md's one-line overview as its description:

   ```sh
   gh repo create <folder name> --private --source . --remote origin --description "<one line>"
   ```

   Creating a repo can't be quietly undone: deleting one later needs a `gh` scope Skye grants herself, or the repo's Settings page.
5. The labels the templates use (`feature`, `bug`) that don't exist yet (`gh label list`): `gh label create <name>`. GitHub's default labels stay.
6. A milestone for each row of SPEC.md's timeline: `gh api 'repos/{owner}/{repo}/milestones' -f title='<name>' -f due_on='<last date>T23:59:59Z'` (leave out `due_on` for a row with no date).

Nothing is committed in this phase, so the first commit (phase 8) can include `workflow.md`.

**A command fails:** stop. Report what was done so far and what wasn't, and ask Skye how to carry on, rather than retrying, which could create something twice.

This phase is done when the repo exists with `origin` pointing at it, and every label and milestone exists.

## 8. Write workflow.md, then make the first commit

1. Follow `setup-project`. In a project this new it finds no merged PRs, history or releases, so it asks about those instead of guessing.
2. Show the first commit: `git status --short`, which should list `SPEC.md`, `CLAUDE.md`, `README.md`, `.gitignore`, `.github/` and `.claude/workflow.md`. Ask about anything else listed before including it.
3. Once Skye approves, commit those files, staged by name, with the message "Set up the project" and the co-author line that this conversation's attribution instructions give. Then push: `git push -u origin main`.

This is the one commit made straight to `main`, because an empty repo has no branch to start a feature branch from. Every later change goes through an issue's branch and a PR.

This phase is done when `origin/main` holds the first commit.

## 9. Hand the first issues to /draft-issue

Turn SPEC.md's **In v1** list into one `/draft-issue` line for Skye to type: the ideas in build order, one per item or small group, starting with a thin slice that runs and deploys end to end, so hosting surprises show up before the real features exist. Show it in a code block.

`/draft-issue` is a skill only Skye starts, so this skill can't run it. Typing the line is her approval to draft, and `/draft-issue` sizes the ideas into a parent with vertical-slice children, sets blocked-by links where order matters, and creates nothing until she approves. Saying "create and plan" there hands the new issues to `/plan-issue`.

This phase is done when Skye has the line.

## Hand back

Report:

- the repo's link;
- every file written, as links;
- the first commit's hash;
- the `/draft-issue` line to type, here or in a fresh session started in this folder.

Then stop.
