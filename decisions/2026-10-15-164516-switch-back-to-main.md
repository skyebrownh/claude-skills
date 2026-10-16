# Switch back to `main` before using skills elsewhere

Issue: #2

Installed skills are symlinks into this folder, so the branch checked out here is the version every project runs. The habit: `git switch main` here before using the skills in another project, and leave `main` checked out between issues.

Considered and left for now: a separate live clone, or git worktrees (a second checkout of the repo in another folder) so that feature branches never touch the installed copy. Worktrees are the fix if the habit ever causes trouble, such as a project running a half-finished skill.
