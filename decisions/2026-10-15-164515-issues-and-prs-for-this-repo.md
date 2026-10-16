# Issues and PRs for this repo too

Issue: #2

This repo now uses the same issue → plan → PR loop as heritage-media-availability (#2), so every change to a skill has a recorded reason that later changes can look back on. It has feature, bug and parent issue templates (blank issues off), a PR template, a short CLAUDE.md, and a `.claude/workflow.md`, so `/ship` and `/merge` run here as in any other project. Merging deploys nothing in the usual sense, but see [Switch back to `main`](2026-10-15-164516-switch-back-to-main.md).

The parent template's `Ships as:` line (one PR, or one PR per child) is what `/ship` reads to decide how a parent's children become PRs (#3). Parent issues get no label, so the repo needed no new one.
