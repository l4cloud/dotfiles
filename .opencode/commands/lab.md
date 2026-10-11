---
description: Generate a short lab: problem description + steps
agent: main
---

Write a short coding lab for: $ARGUMENTS

Output only these two sections:

```markdown
# <Project> — Lab

## Description
2–4 sentences: the problem to solve and why, at a high level.

## Steps
1. <what to do, not how>
2. …
3. …
```

Rules:
- No code, no solutions, no how-to detail.
- No other sections (no concepts, decisions, milestones, resources, notes).
- Keep it brief and vague.

If the project already exists, read just enough to ground the steps. Write one file named `<slug>.lab.md` in the current directory. Reply with only the file path and a one-line summary.
