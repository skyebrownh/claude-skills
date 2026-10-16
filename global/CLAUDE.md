# Global preferences (all projects)

These are my personal defaults. A project's own CLAUDE.md overrides anything here.

## About me

- My pronouns are she/her.
- I have a computer science background but I'm new to vibe coding. When a project
  uses a framework or tool I'm new to, assume I'm learning it.
- When you use a concept, pattern, or command I might not know, give me a concise,
  high-level explanation of it.
- My preferred languages are Python and JavaScript.
- I'm on macOS with zsh.
- After each step, explain what you did and why in plain language. Keep it short.
- If something is unclear or two instructions conflict, ask me. Don't guess.

## How I like to work

- Plan first, and wait for my approval before writing code. In projects that use `/plan-issue`, that's the plan.
- Build in small steps. Don't build ahead of the current task; suggest anything
  extra as a separate follow-up instead.
- Add or update tests for any behavior you change, and run the existing tests
  before calling work ready.
- Ask before deleting files or running anything that wipes data (e.g. `rm -rf`,
  dropping a database).
- When work is ready for review, give me: what changed (with file links), the
  automated test results, and, for app work or whenever there's something to
  click or run, numbered manual test steps (what to do, what I should see).
  In projects that use `/handover`, that's the handover. Then wait.
- Ask before adding any dependency. Prefer the standard library and the
  framework's built-ins.

## Git and GitHub

- Commit on the issue's feature branch as the work goes, never on the default
  branch. Don't push until I approve (with `/ship` in projects that use it, or
  in chat).
- Never push to the default branch, merge a PR, or force-push without my explicit
  approval. If merging deploys, remind me before asking.
- Don't change repo settings or delete remote branches without asking.
- For long `gh` text (issue bodies, comments, PR descriptions), write it to a file
  in the scratchpad directory and pass it with `--body-file`.

## Code style

- Comment non-obvious logic with *why*, not just *what*. Templates and JavaScript
  get comments too. Don't restate obvious code.
- I read the code to learn from it, so clarity beats cleverness.

## Secrets

- Never put secrets in code, commits, or chat. Read them from environment variables.
- Keep `.env` git-ignored, and provide a `.env.example` with placeholder values only.

## Python

- For new Python projects I start, prefer uv. Existing projects keep their own tooling.
