---
name: merge
description: Merge an approved pull request (which may deploy), run the after-merge clean-up (closing any parent issue the merge finished), and list what to check after the deploy. Running /merge is Skye's approval to merge. Reads the merge style and deploy facts from .claude/workflow.md. Use only when Skye types /merge.
disable-model-invocation: true
argument-hint: "<PR#>"
---

# Merge a pull request

Skye typed `/merge $ARGUMENTS`. **That is her approval to merge** that pull request.

If no PR number was given, ask for it. Don't guess it from the current branch.

Check everything first, and stop at the first problem, saying what's wrong and what to do. **If anything fails before or during the merge, stop and report it before any clean-up.** Put each step below on the task list.

## 0. Read the project's facts

Read `.claude/workflow.md` at the repo root. You need these sections: **Default branch** and **Merging**, plus **After a deploy, check** and **Releases** if they exist.

- **It's missing, or Merging still holds `<placeholders>`:** stop and say to run `/setup-project` first. Don't guess how this project merges or whether it deploys.
- **The project is on an older version of the process:** its version is the number under **Process version** (1 if that section is missing), and the current version is the newest heading in [setup-project's migrations.md](../setup-project/migrations.md). If the project's is lower, stop. Name each migration it's missing (e.g. "2: Parent PRs") and say to run `/setup-project`, which applies them. Running on an old setup could follow facts that no longer mean what this skill expects.
- **Merging deploys: yes:** say where it deploys before merging, in one line, so the approval is an informed one.

## 1. Check the pull request

```sh
gh pr view <PR> --json number,title,state,baseRefName,headRefName,isDraft,mergeable,mergeStateStatus,closingIssuesReferences,body
```

Stop if:

- **It isn't open**, it's a draft, or its base isn't the default branch.
- **It closes no issue.** Every PR should have a `Closes #N`. Ask how to proceed.

**Wait out `UNKNOWN`.** Just after a push or another merge, GitHub often reports `mergeable` as `UNKNOWN` while it recalculates. Check again every few seconds for up to about a minute, and don't merge while it's `UNKNOWN`.

- **`MERGEABLE`:** carry on.
- **`CONFLICTING`:** stop. Explain which files conflict (`gh pr view <PR> --json files`) and how to resolve it: **merge the default branch into the PR's branch**, keep both sides where both are wanted, and push normally. Committed history is never rewritten, so no rebase and no force-push. That merge commit is a commit, so it needs Skye's approval like any other.
- **Still `UNKNOWN` after a minute,** or a `mergeStateStatus` that blocks merging: stop and report it.

## 2. Merge

Count `closingIssuesReferences`. One issue means a single-issue PR, and more than one means a parent PR (it closes a parent and its children). Use the style **Merging** gives for that kind:

| Style | Command |
| --- | --- |
| squash | `gh pr merge <PR> --squash --subject "<issue title> (#<PR>)"` (get the title with `gh issue view <N> --json title`) |
| rebase | `gh pr merge <PR> --rebase` |
| merge commit | `gh pr merge <PR> --merge --subject "<PR title> (#<PR>)"` |

If **Merging** says parent PRs aren't used but this one closes several issues, stop and ask.

If the merge command fails, **stop and report it**, and run none of the clean-up.

## 3. Clean up after the merge

The branch may never have been checked out in this folder: it could have been built in a worktree, or shipped while this folder was on another branch. So check where it is first.

**This folder has uncommitted or untracked changes** (`git status --porcelain`): stop before switching branches, which would carry them along, and ask Skye what they are.

Run each step and report its result:

1. Update the default branch: `git switch <default> && git pull --ff-only`.
2. Confirm nothing was left behind: `git diff <default> <branch>` should be empty. If there's no local branch (`git branch --list <branch>` prints nothing, because it was shipped from another clone), compare with `origin/<branch>` instead. If neither exists (GitHub deleted the branch after merging, and this clone has no copy), skip this step and the next, and say so: there's nothing here to compare or delete. If anything differs, stop and report it before deleting anything.
3. Delete the local branch, if there is one:
   - **A worktree still has it checked out** (`git worktree list` shows `[<branch>]`): remove that worktree first, with `git worktree remove <its path>`, because git won't delete a branch a worktree is using. If the worktree has uncommitted changes, the command refuses: stop and ask Skye about them.
   - Then `git branch -D <branch>`. The capital `-D` is needed after a squash or rebase merge: those make new commits, so git doesn't recognise the branch as merged.
4. Prune: `git fetch --prune`. If the remote branch still exists (`git ls-remote --heads origin <branch>`), say so, and don't delete it: deleting a remote branch needs Skye's OK.
5. Check that every issue the PR closes is now closed: `gh issue view <N> --json state`. GitHub's issue lists can lag for a few seconds, so trust `gh issue view`. For a parent PR, also list the parent's sub-issues (`gh api --paginate repos/{owner}/{repo}/issues/<parent>/sub_issues --jq '.[] | "#\(.number) \(.state)"'`) and name any still open: that child was missing from the PR's `Closes` lines.
6. Close any parent this merge finished. A child's PR only says `Part of #P`, which isn't a closing keyword, so GitHub leaves the parent open after its last child merges. Start from each issue the PR closes (for a parent PR, from the parent), and for its parent, once per parent even when the PR closes several of its children:
   - **Find it** with step 1 of [finding-the-parent.md](../ship/finding-the-parent.md). No parent (a 404): nothing to do.
   - **Read its Ships as** the way step 2 of that file does, but don't follow its stop. Anything but `one PR per child`, or no line at all: skip this parent, and say why in one line, because the merge has already happened. (A `one PR` parent is closed by its own PR.)
   - **List its children:** `gh api --paginate repos/{owner}/{repo}/issues/<P>/sub_issues --jq '.[] | "#\(.number) \(.state) \(.state_reason) children=\(.sub_issues_summary.total) \(.title)"'`.
   - **Count the issues this PR closes as closed,** whatever the list says: like the issue lists, it can lag for a few seconds after the merge.
   - **Some are still open:** report its progress, e.g. "#27: 2 of 4 children still open (#30, #31)", and go no further up.
   - **All are closed:** close it as completed. A child closed as not planned counts as done, so a dropped child can't keep its parent open forever. Write a comment to a file in the scratchpad saying every child is closed, and listing each as `#C <title> (PR #X)`, with the PR from `gh issue view <C> --json closedByPullRequestsReferences`. Where a child has no PR, say instead "its own children all closed" (children above 0) or "closed by hand", and add "not planned" where its `state_reason` says so. Then:

     ```sh
     gh issue close <P> --reason completed --comment "$(cat <file>)"
     ```

     This needs no separate approval: it follows from how Skye chose to ship the parent, and a closed issue can be reopened. Then repeat this item from the parent you closed, because it may have finished its own parent.
7. Show `git log --oneline -1`, the new commit on the default branch.

## 4. Say what to check after the deploy

Skip this step if **Merging deploys** is no.

**Don't check the live sites yourself.** Skye checks the deploy. List each item under **After a deploy, check**, and add anything the PR's "How to test" says to do after merging. If the PR changes nothing in the running app (only docs or skills), say so: the sites should look the same.

## 5. Wrap up

Report briefly: the merge (commit and subject), each clean-up result (including each parent closed, or its progress), and the deploy checklist.

Then mention what's next, if it's clear. For example, if this merge leaves the PR's milestone with no open issues, say so (`gh issue list --milestone "<milestone>" --state open`). If **Releases** describes a point like this one, suggest a release and draft its title, but **never create one**: a release publishes a tag and needs Skye's separate approval.
