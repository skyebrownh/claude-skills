# Cheaper models for lookup-only subagents

Issue: #54

Some skills start subagents that only look things up. The built-in Explore agent isn't pinned to a model: it inherits the main conversation's model (subagents docs, code.claude.com/docs/en/sub-agents), usually Opus. So each lookup subagent below saved something by pinning, and none was dropped.

| Skill and step | Subagent | Model | Why |
| --- | --- | --- | --- |
| `draft-issue` step 2 | one Explore per idea, for the files it touches | `haiku` | It reports files and a rough size, and Skye reads the draft before anything is created. |
| `grilling` step 2 | one Explore per fact lookup | `haiku` | It reports one fact, and the main session checks it against the question. `new-project` gets this through `grilling`. |
| `plan-issue` step 2 | Explore subagents reading the code the work affects | `sonnet` | Their reports decide every file the plan names, so they get the stronger of the two cheap models. |

**Short names only.** Skills say `haiku` or `sonnet`, never a full model ID, so a skill doesn't go stale when a model is retired.

**Why subagents are the place to choose.** Switching the main session's model mid-conversation loses the prompt cache. A subagent starts with fresh context, so choosing its model costs no cache.

**Not pinned, on purpose.** These are judgement-heavy, and a cheaper model could lower quality without anyone noticing:

- `fresh-eyes`, in both modes
- `build`'s parallel builders
- `whats-next`'s ranking
- `retro`'s transcript reading
- `new-project`'s stack research

Pinning any of them could be a later issue, with its own quality check. Multi-model review stays left out, as in [2026-10-15-190045-review-skill-only-reports.md](2026-10-15-190045-review-skill-only-reports.md).
