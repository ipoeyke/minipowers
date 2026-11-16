# PR Description Template

The PR is written for a reviewer who was not there. It must answer four
questions: what changed, what was checked, what the risks are, and what
the pipeline had to fix.

## Title

`<type>: <short imperative>`, for example
`feat: add stage audit checklist and plan check stage`. Standalone and
searchable: not "fix bug" or "update X".

## Body

Copy the skeleton, keep its headings and their order, and replace every
`<...>`.

```markdown
## What & Why

<One paragraph: the intent - what the user set out to accomplish, in their terms. Not a restatement of the diff. Include the key decisions and tradeoffs.>

## Changes

* <file/area>: <what changed>
* <file/area>: <what changed>

## Validation

* **Review:** <N> independent round(s) vs intent - round 1 on the full diff, later rounds on the files the fixes touched - <N> finding(s), all resolved or explicitly deferred (see Risks).
* **Test:** `<test command as run, e.g. pytest or make test>` - <passed/summary>
* **Lint/types:** `<lint and type commands as run, e.g. ruff check or make check>` - <passed>
* **Docs:** <updated path/to/doc.md | no doc impact>

## Fixes the review caught (not in the original change)

<List each auto-fix or user-directed fix the reviewer surfaced that the first pass missed, so the reviewer can scan them. Omit this section if there were none.>

* <finding -> fix>

## Risks/deferred

<Anything skipped, any ask-user finding the user chose to defer, backwards-compat notes, migration concerns. "None" if truly none.>
```

After the last section, add the attribution line the session requires.

## Where Each Part Comes From

- **What & Why:** `intent.md` for the problem and outcome, the spec for
  the chosen approach and what it was chosen over. A plan Amendment that
  changed a decision is a key decision.
- **Changes:** `git diff --stat BASE..HEAD`, grouped by file or area. The
  `docs/changes/<id>/` record is one line.
- **Review:** the final review's rounds and every finding it raised:
  Critical, Important, and Minor. A line the reviewer declined to judge
  is not a finding. On the heavy tier, add the task reviews' fixed
  findings to the count.
- **Test, Lint/types:** each command Final Review ran, as run, with its
  one-line result. A failure the baseline also has is written as
  pre-existing, with the test named. A check that was not run is written
  "not run" with the reason.
- **Docs:** the living docs and any other doc the diff touches.
- **Fixes the review caught:** every Critical or Important finding a
  fixer resolved, task reviews included. Mark a fix that came from an
  ask-user ruling "user-directed".
- **Risks/deferred:** ask-user findings ruled defer or drop; Minors left
  and why; lines the reviewer declined to judge and why each was dropped;
  checks not run; pre-existing failures; removed or renamed settings,
  flags, and interfaces; the Assessment's CLAUDE.md proposals.

Every plan Amendment and every human ruling lands in one of these parts.

## Rules

- Be honest: if the review deferred a finding or a step was skipped at
  the user's request, say so in **Risks/deferred**. A skipped check is
  stated, never hidden.
- Do not claim CI is green, will be green, or is expected to pass. This
  gate stops at PR raised; CI is the human's and the remote's gate.
