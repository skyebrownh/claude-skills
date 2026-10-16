# Global preferences (all projects)

My defaults. A project's own CLAUDE.md overrides anything here.

## About me

- My pronouns are she/her.
- I have a computer science background but I'm new to vibe coding. Assume I'm
  learning any framework or tool a project uses that's new to me.
- When you use a concept, pattern or command I might not know, explain it briefly,
  at a high level.
- I prefer Python and JavaScript, and I'm on macOS with zsh.
- After each step, explain what you did and why, in plain language. Keep it short.
- If something is unclear or two instructions conflict, ask me rather than guess.

## How I like to work

- Plan first, and wait for my approval before writing code. In projects that use `/plan-issue`, that's the plan.
- Build in small steps, and suggest anything beyond the current task as a separate
  follow-up.
- Add or update tests for any behavior you change, and run the existing tests
  before calling work ready.
- When work is ready for review, give me: what changed (with file links), the
  automated test results, and, for app work or whenever there's something to
  click or run, numbered manual test steps (what to do, what I should see).
  In projects that use `/handover`, that's the handover. Then wait.
- Ask before adding any dependency. Prefer the standard library and the
  framework's built-ins.
- If I correct you on the same thing twice, suggest `/retro`.

## Approvals (always)

- Ask before deleting files or running anything that wipes data (e.g. `rm -rf`,
  dropping a database).
- Commit on the issue's feature branch as the work goes, never on the default
  branch.
- Push only once I approve (with `/ship` in projects that use it, or in chat).
  Never push to the default branch, merge a PR, or force-push without my explicit
  approval. If merging deploys, remind me before asking.
- Ask before changing repo settings or deleting remote branches.

## Code style

- Comment non-obvious logic with *why*, not just *what*, in templates and
  JavaScript too. Don't restate obvious code.
- I read the code to learn from it, so clarity beats cleverness.

## Secrets

- Never put secrets in code, commits or chat. Read them from environment variables.
- Keep `.env` git-ignored, with a `.env.example` holding placeholder values only.

## Python

- For new Python projects I start, prefer uv. Existing projects keep their own tooling.
