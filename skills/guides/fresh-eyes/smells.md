# Code smells

A fixed list of code smells from Martin Fowler's _Refactoring_ (chapter 3), adapted from Matt Pocock's `code-review` (MIT; see `decisions/2026-10-15-190045-review-skill-only-reports.md` in the skills repo). The review skill pastes this whole file into the Standards reviewer's prompt, because a subagent can't open the skill's files.

Two rules apply to every smell:

- **The project's CLAUDE.md wins.** Where it allows or asks for something this list would flag, leave the smell out.
- **A smell is always a judgement call.** Report it as "possible Feature Envy", never as a hard breach, and skip anything a linter or formatter already enforces.

Each smell reads: what it is, then how to fix it.

- **Mysterious Name:** a function, variable or type whose name doesn't say what it does or holds. Rename it. If no honest name comes to mind, the design itself is unclear.
- **Duplicated Code:** the same logic appears in more than one place in the change. Pull the shared part into one function and call it from both.
- **Feature Envy:** a function that uses another object's data more than its own. Move it next to the data it uses.
- **Data Clumps:** the same few fields or parameters keep travelling together. Bundle them into one type and pass that.
- **Primitive Obsession:** a plain string or number standing in for a real concept (a money amount, an email address). Give the concept its own small type.
- **Repeated Switches:** the same `switch` or `if` chain on the same value appears in several places. Replace it with one lookup table both places share, or with polymorphism.
- **Shotgun Surgery:** one logical change needs small edits scattered across many files. Gather the things that change together into one module.
- **Divergent Change:** one file is edited for several unrelated reasons. Split it so each part changes for one reason.
- **Speculative Generality:** abstractions, parameters or hooks for needs the issue doesn't have. Remove them, and add them back when a real need appears.
- **Message Chains:** long `a.b().c().d()` navigation that ties the caller to the shape of other objects. Hide the walk behind one method on the first object.
- **Middle Man:** a class or function that mostly passes calls straight on. Remove it and call the real target directly.
- **Refused Bequest:** a subclass that ignores or overrides most of what it inherits. Drop the inheritance and use composition.
