---
name: merge
description: Merge an approved pull request (which may deploy), run the after-merge clean-up, and list what to check after the deploy. Running /merge is Skye's approval to merge. Reads the merge style and deploy facts from .claude/workflow.md. Use only when Skye types /merge.
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

Run each step and report its result:

1. Update the default branch: `git checkout <default> && git pull --ff-only`.
2. Confirm nothing was left behind: `git diff <default> <branch>` should be empty. If it isn't, stop and report what differs before deleting anything.
3. Delete the local branch: `git branch -D <branch>`. The capital `-D` is needed after a squash or rebase merge: those make new commits, so git doesn't recognise the branch as merged.
4. Prune: `git fetch --prune`. If the remote branch still exists (`git ls-remote --heads origin <branch>`), say so, and don't delete it: deleting a remote branch needs Skye's OK.
5. Check that every issue the PR closes is now closed: `gh issue view <N> --json state`. GitHub's issue lists can lag for a few seconds, so trust `gh issue view`. For a parent PR, also list the parent's sub-issues (`gh api --paginate repos/{owner}/{repo}/issues/<parent>/sub_issues --jq '.[] | "#\(.number) \(.state)"'`) and name any still open: that child was missing from the PR's `Closes` lines.
6. Show `git log --oneline -1`, the new commit on the default branch.

## 4. Say what to check after the deploy

Skip this step if **Merging deploys** is no.

**Don't check the live sites yourself.** Skye checks the deploy. List each item under **After a deploy, check**, and add anything the PR's "How to test" says to do after merging. If the PR changes nothing in the running app (only docs or skills), say so: the sites should look the same.

## 5. Wrap up

Report briefly: the merge (commit and subject), each clean-up result, and the deploy checklist.

Then mention what's next, if it's clear. For example, if this merge leaves the PR's milestone with no open issues, say so (`gh issue list --milestone "<milestone>" --state open`). If **Releases** describes a point like this one, suggest a release and draft its title, but **never create one**: a release publishes a tag and needs Skye's separate approval.
