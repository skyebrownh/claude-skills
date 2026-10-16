---
name: draft-issue
description: Turn one idea, or several, into draft GitHub issues from the project's templates (a parent with children for bigger work), after a short grilling, and create them only once Skye approves. Use only when Skye types /draft-issue.
disable-model-invocation: true
argument-hint: "<one idea or several>"
---

# Draft issues from ideas

Skye typed `/draft-issue $ARGUMENTS`. **That is her approval to draft, not to create.** Nothing is created, edited or commented on in GitHub until she approves the drafts in chat, because creating an issue publishes it and notifies anyone watching the repo.

Check everything first, and stop at the first problem, saying what's wrong and what to do. Put each step below on the task list.

This skill needs no `.claude/workflow.md`: the templates, labels and SPEC.md are found by looking, so it works in a new project before `/setup-project` has run.

## 1. Split into ideas

Break `$ARGUMENTS` into separate ideas, one change each:

- **Number each idea** and restate it in one plain line, so Skye can see how you understood it.
- **Two ideas look related** (one needs the other, or they touch the same thing): suggest combining them, and let Skye decide in step 4. Until she does, keep them apart.
- **Anything that isn't an idea** (context, an aside): skip it, and say what you skipped.

Unrelated ideas stay separate all the way through: each becomes its own draft, approved on its own.

This step is done when every idea has a number and a one-line restatement, and every skipped part is noted.

## 2. Read the sources

Read these before drafting anything:

- **The templates** in `.github/ISSUE_TEMPLATE/`. Each one's frontmatter (the `---` block) gives its name and default labels; the rest is the body. **There are none:** stop and ask Skye how this project's issues should look, because a draft with no template is a guess.
- **`SPEC.md`,** if it exists: the requirement IDs, and any out-of-scope lists (such as Later or Non-goals).
- **The project's CLAUDE.md:** its conventions for issues, labels and milestones.
- **The labels and milestones that exist:** `gh label list --json name,description` and `gh api 'repos/{owner}/{repo}/milestones?state=open' --jq '.[].title'`.
- **The open parents** (issues with children): `gh api --paginate 'repos/{owner}/{repo}/issues?state=open&per_page=100' --jq '.[] | select(.pull_request | not) | select(.sub_issues_summary.total > 0) | "#\(.number) \(.title)"'`. `--paginate` reads every page, and the `pull_request` filter drops PRs, which this endpoint also returns.
- **The code each idea touches:** one read-only Explore subagent per idea, all started in one message so they run in parallel. They report which files are involved and how big the change looks.

This step is done when every source above is read or known to be missing, and every Explore subagent has reported.

## 3. Look for duplicates

For each idea, search **open and closed** issues:

```sh
gh issue list --state all --search "<a few key words>" --json number,title,state
gh issue view <N> --json title,body,state,comments
```

**An idea matches an existing issue:** say "matches #N (open/closed)", and suggest a comment in place of a new issue: on the open issue, adding what's new; or, if a closed issue's problem has come back, a new issue that links to it. Skye decides in step 4.

This step is done when every idea has been searched, and each match is noted with its suggested comment.

## 4. Grill

Follow `grilling`, once, covering every idea. Send the first round with the restatements from step 1 and any matches from step 3, and number each question by its idea (1.1 and 1.2 for idea 1, 2.1 for idea 2), so Skye can answer every idea in one reply.

Ask only what SPEC.md and the code can't answer:

- **Scope:** what's in and what's out. An idea on SPEC.md's out-of-scope list: quote the line, and ask whether to draft it anyway.
- **Size:** one issue, or a parent with children (step 5).
- **Template:** which one fits.
- **Parent:** whether it belongs under an open parent from step 2.
- **Ships as,** for a new parent: recommend `one PR` or `one PR per child` with a reason, as a question. How the work ships is Skye's call, so it's never decided for her.
- **Milestone and labels:** recommend from those that exist. A label that would help but doesn't exist yet is its own question; this skill never creates one.

This step is done when `grilling` ends with Skye confirming nothing is left open for any idea.

## 5. Size each idea

One issue is one sitting, one branch, one PR.

- **Bigger work** becomes a parent, from the parent template, whose children are **vertical slices**: each a thin piece that works end to end on its own, so it can be built, tried and shipped alone.
- **Blocked-by links** go only where order matters: a child that needs another child's work first is blocked by it. Children that could be built in any order have none.
- **Independent ideas** get no links between them.
- **It fits an existing open parent:** propose it as a child of that parent, and draft the line to add to the parent's Children list, so both are approved together.

This step is done when every idea is one issue, a parent with children, or a child of an existing parent, and each blocked-by link has a reason.

## 6. Draft

For each issue, write:

- **Title,** template, milestone and labels. The labels are the template's default labels plus any suggested ones, because `--body-file` skips the template's frontmatter, so its labels have to be passed by hand.
- **Parent and blocked-by,** if any.
- **Body:** every heading of the matching template, filled in, with its `<!-- … -->` guidance comments removed. Requirement IDs go where the template asks for them (such as a Delivers section). Acceptance criteria are checkboxes that someone can check by running the work or a test. Out of scope is a list.
- **A new parent's `**Ships as:**` line:** exactly `one PR` or `one PR per child`, from Skye's answer in step 4, because `/ship` reads that line and stops on anything else.
- **A new parent's Children list:** each child as `#` and its title in brackets, in order (`1. # (Add the form)`), because the numbers come only when the children are created in step 7.
- **A child of an existing parent:** the line to add to that parent's Children list, written the same way.
- **A duplicate:** the comment to post on the existing issue, in place of a new issue.

Show every draft in one message, grouped by idea, ending with a short summary (for example: "idea 1: a parent and 3 children; idea 2: a comment on #12"). Then stop. Skye approves all, some, or edits them. Treat anything she doesn't mention as not approved, and ask about it.

This step is done when Skye has approved, edited or turned down every draft.

## 7. Create what was approved

Creating an issue can't be undone quietly: it's public at once, and can only be closed afterwards. So create exactly the approved drafts, with Skye's edits.

1. Write each body, and each approved comment, to its own file in the scratchpad directory.
2. Per idea, create the parent first, then each child in order:

   ```sh
   gh issue create --title "<title>" --body-file <file> --label <label> --milestone "<milestone>" --parent <P> --blocked-by <numbers>
   ```

   Leave out `--parent`, `--blocked-by` or `--milestone` when the draft has none. Each child's `--blocked-by` is the real numbers of the children its draft names as blockers, which were created before it because of the order above.
3. Fill the real numbers into each parent's Children list, with `gh issue edit <P> --body-file <file>`:
   - **A new parent:** replace each `# (<title>)` with its child's number (`1. #23`).
   - **An existing parent:** re-read its body (`gh issue view <P> --json body`), add the approved line, and write it back. If its Children list changed since you drafted, show the new version and ask before writing.
4. Post each approved comment with `gh issue comment <N> --body-file <file>`.

**A command fails:** stop. Report what was created so far, with links, and what wasn't, and ask Skye how to carry on, rather than retrying, which could create an issue twice.

This step is done when every approved issue, Children-list edit and comment exists on GitHub, and you have each link.

## 8. Hand back

Report the link to every issue created and comment posted, and anything Skye turned down or left open.

- **Skye asked to plan some of them** (such as "create and plan"): follow `plan-issue` for the issues she named.
- **Otherwise:** suggest planning them with `plan-issue`, naming the issues, and stop.

This step is done when Skye has every link, and either the issues she named are being planned or she has the suggestion to plan them.
