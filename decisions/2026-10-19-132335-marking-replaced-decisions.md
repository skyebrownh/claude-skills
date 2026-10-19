# Marking replaced decisions

Issue: #50

Some older decisions state rules a later decision changed, and nothing in the older file said so: the only link ran from the newer file back ("This replaces the … bullet in …"). Someone reading `decisions/` alone could take the old rule as current. Now an older file gets a `Replaced in part by:` line linking the newer one, as `decisions/README.md` describes.

- **One marker line, and nothing else changes.** An old decision records what was decided at the time, so its text stays as written. The marker only says where to look for what holds now.
- **`Replaced in part by:` by default,** and `Replaced by:` only when the whole decision no longer holds. So far every replacement has changed one or two bullets, not a whole decision.
- **After a blank line under the `Issue:` line,** so GitHub shows it as its own paragraph rather than running it onto the `Issue:` line, and a reader sees it before the old rules.
- **On the older file, not a list in the README.** A list of replacements would bring back the running index #33 removed, and every branch that adds a decision would conflict over it.
- **The newer decision's branch adds the marker,** in the same change, because that's when someone knows what was replaced. The PR template's decisions line asks for it, which is enough without a CLAUDE.md rule.
- **Five files marked:** `building-on-branches` and `shipping-committed-branches` by `fixing-conflicts-on-the-branch`, `review-skill-only-reports` and `handovers-on-the-issue` by `clearer-reports`, and `parent-and-child-issues` by `shipping-committed-branches`.

Left out: `switch-back-to-main`, since worktrees were adopted only for `/build`, and `first-version`, whose roadmap is a plan, not a rule. The "later replaced" notes in `docs/skills/build.md` and `docs/skills/ship.md` already link the newer decision.
