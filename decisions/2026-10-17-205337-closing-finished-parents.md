# Closing finished parents

Issue: #34

A parent that ships as `one PR per child` stayed open after its last child merged, because each child's PR says `Part of #P`, which isn't a closing keyword. The roadmap, #1, had to be closed by hand. `/merge` now closes it.

- **In `/merge`, not a new skill.** The merge is the moment the last child closes, and `/merge` already lists a parent's sub-issues, so it's a new item in its clean-up list. A separate `/close-parent` would be one more command to remember to run.
- **No second prompt.** Running `/merge` approves the merge, and closing the parent follows from how Skye chose to ship it. A closed issue can be reopened.
- **A child closed as not planned counts as done,** and the closing comment names it, so a dropped child can't keep its parent open forever.
- **Not finished yet:** `/merge` reports progress ("#27: 2 of 4 children still open"), which is a free check on how far the parent has got.
- **It walks up.** Closing a parent may finish its own parent (#18 sat inside #1), so the check repeats from each parent it closes, and starts from the parent after a parent PR too.
- **Other Ships as values are skipped with a note, not a stop,** because the merge has already happened. A `one PR` parent is closed by its own PR's `Closes` line (`2026-10-15-172511-parent-and-child-issues.md`).
- **The closing comment lists each child with its PR,** so the parent records how its work shipped.

Left out: editing the parent's Children list, since GitHub already shows each linked issue's state.
