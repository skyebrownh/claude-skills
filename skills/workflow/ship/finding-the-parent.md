# Finding an issue's parent and its branch

`/ship`, `/build` and `/handover` all need to know whether an issue belongs to a parent, how that parent ships, which branch is the parent's, and which children are already folded into it, and `/plan-issue` needs the first of these. The steps are here once, so the skills can't drift apart.

## 1. Is it a parent, a child, or neither?

```sh
gh api repos/{owner}/{repo}/issues/<N> --jq .sub_issues_summary.total   # above 0: #N is a parent
gh api repos/{owner}/{repo}/issues/<N>/parent --jq .number              # a 404 means #N has no parent
```

## 2. How does the parent ship?

A parent's **Ships as** is the line in its body (`gh issue view <P> --json body`) starting `**Ships as:**`. Remove any `<!-- … -->` comment from it. What's left must be `one PR` or `one PR per child` (any case).

**It's anything else, or the line is missing:** stop, and ask Skye to set it on the parent. How the children become PRs is her decision, so never guess it.

## 3. Which branch is the parent's?

Only a parent that ships as `one PR` has a branch of its own: its children are folded into it, and it becomes the one PR. It's the local branch matching `<P>-*`:

```sh
git branch --list '<P>-*'
```

- **Exactly one:** that's the parent's branch.
- **More than one:** stop, and ask Skye which it is.
- **None:** `/build` creates it (it says how). Any other skill stops: with no parent branch there's nothing built on it yet, so ask Skye whether a child was built somewhere else.

## 4. Is a child folded into the parent's branch?

A child of a `one PR` parent **is folded** when its work is a commit on the parent's branch, found by its title:

```sh
git log --format=%s <default branch>..<parent's branch> | grep -Fx '<child title>'
```

It prints the title when the child is folded. Matching by title works because a fold commit's subject is always the child's title. The child stays open until the parent's PR merges, so its state can't tell you.
