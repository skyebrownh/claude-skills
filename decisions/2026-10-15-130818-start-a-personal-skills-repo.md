# Start a personal skills repo

The workflow built for heritage-media-availability (spec → issue → plan → build → handover → `/ship` → `/merge`) is worth reusing in new projects. Two popular published collections were reviewed first:

- **Matt Pocock's skills** ([mattpocock/skills](https://github.com/mattpocock/skills), MIT). The closest fit. Borrowed the repo shape (skills grouped into bucket folders, symlinked into `~/.claude/skills` by a script), the split between skills Claude may start and skills only the human starts, the per-project setup skill, and the writing rules in `writing-skills`. Not adopted wholesale: some of his skills commit or create issues without an approval step, and his vocabulary differs from Skye's.
- **pstack** by Lauren Tan ([cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack), MIT). Built for Cursor, many agents working in parallel, and acting without asking, which conflicts with Skye's approval gates. Kept as a source of ideas for later (an adversarial review step, putting a skill's steps on the task list, turning repeated corrections into skill edits).

Decided: build Skye's own skills, rewriting borrowed ideas in her own words and conventions, rather than installing either collection.
