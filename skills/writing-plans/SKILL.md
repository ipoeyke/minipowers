---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

The heavy-tier path, reached via brainstorming's tier triage.

Write a plan for an implementer who is a skilled developer with fresh
context, who knows nothing about this codebase or domain and is weak at
test design. The plan's job is to remove ambiguity: files, interfaces,
test intent, and constraints, as bite-sized tasks. DRY, YAGNI, TDD.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

Save to `docs/plans/YYYY-MM-DD-<feature-name>.md` unless the user prefers
another location. Do not commit it or the spec: subagent-driven-development
commits both at kickoff.

If the spec covers multiple independent subsystems, suggest one plan per
subsystem, each producing working, testable software.

## File Structure

Before defining tasks, map which files are created or modified and what
each is responsible for. This locks in the decomposition.

- One clear responsibility per file, with well-defined interfaces. Prefer
  small, focused files; files that change together live together; split
  by responsibility, not technical layer.
- In existing codebases, follow established patterns. Split a file you
  modify only if it has grown unwieldy.
- Living docs are an owned file: each change in the spec's Living docs
  impact section goes into the task whose deliverable makes the old text
  wrong, never a trailing docs-only task.
- Shared test fixtures are an owned file: when two or more tasks build the
  same inputs, name the fixture file (e.g. `tests/<pkg>/conftest.py`), the
  task that creates it, and the tasks that consume it. A fresh subagent
  cannot know a helper exists.

## Tasks

A task is the smallest unit with its own test cycle that a reviewer could
reject while approving its neighbor. Fold setup, configuration, and docs
into the task whose deliverable needs them. Each task ends with an
independently testable deliverable, in steps of one action each.

Each task MUST pin down exactly:

- **File paths**, created vs modified.
- **Interfaces**: names, parameter and return types, config keys and
  defaults, error types, record shapes. Type every closed set of values
  (currencies, kinds, statuses) as an enum, never a bare string or id
  prefix.
- **Test intent**: what each test proves, the edge cases it covers, and
  the expected red-phase failure.
- **Binding constraints**: thresholds, formats, and invariants copied
  verbatim from the spec.
- **A reason for each non-obvious constraint**: one domain-terms clause,
  or the stable public source it comes from (a published paper, a standard
  or RFC, a named public data series). Implementers may not cite the plan
  in code, so a value without a reason becomes a magic number or a "per
  the plan" comment.

Plan-time code is written blind and ships untested guesses as
requirements; hardcoded seeds and expected values in plan-authored
fixtures are the most common defect. Include literal code only where it is
load-bearing - a non-obvious algorithm, a statistical formula, a tricky
shell invocation, an API contract other tasks compile against - and mark
it binding. Describe everything else by intent.

Never write "TBD", "TODO", "implement later", "fill in details", "add
appropriate error handling", "add validation", "handle edge cases" (name
them), "write tests for the above", "similar to Task N"
(repeat the requirements), or a reference to a type or function no task's
Interfaces block defines.

## Feasibility Probe

Any pass/fail criterion the code will enforce (a statistical check, a
tolerance band, a minimum count, a correlation floor) must be shown
reachable at default config before you pin it. Run a scratch simulation
outside the repo, state the expected false-alarm rate, and pin the
threshold from that evidence. A criterion that cannot pass otherwise
surfaces mid-execution as several recalibration commits.

## Test Commands

Use the project's documented test commands (README, Makefile,
CONTRIBUTING, CI config), including an already-configured parallel runner
such as pytest-xdist; add no dependencies for speed. Never write a
full-suite run into a task step: the implementer gets one full run before
its final commit, and the controller runs the suite before the final
review.

## Plan Header

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use minipowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence]

**Architecture:** [2-3 sentences]

**Tech Stack:** [Key technologies]

## Global Constraints

[Project-wide requirements from the spec, one line each with exact values:
version floors, dependency limits, naming rules, platform requirements.
Also the architectural invariants: dependency direction ("nothing outside
X imports X"), ownership ("only the repository layer writes to the
database"), and state invariants ("a balance never goes negative").
Reviewers check only what this block lists; every task implicitly
includes it.]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [exact signatures from earlier tasks]
- Produces: [exact names and types later tasks rely on - an implementer
  sees only their own task]

- [ ] **Step 1: Write failing tests** - [per test: name, behavior proved,
  edge cases, expected red-phase failure]
- [ ] **Step 2: Run them; they fail for the right reason**
  Run: `pytest tests/path/test.py -v`
  Expected: FAIL with [missing symbol, wrong value]
- [ ] **Step 3: Implement** - [requirements + Interfaces; literal code only
  if load-bearing, marked binding]
- [ ] **Step 4: Run this task's tests and lint on touched files; all green**
- [ ] **Step 5: Commit** - `git commit -m "feat: add specific feature"`
````

Markdown tables: no cell may contain a literal `|`, not even inside
backticks. Write closed values as separate code spans
(`` `gain`, `loss`, `flat` ``) and unions with "or" (`int or None`).

## Self-Review

Check the plan against the spec yourself and fix inline:

1. **Coverage:** every spec requirement maps to a task; add missing ones.
2. **Placeholders:** none of the forbidden patterns above.
3. **Type consistency:** names and signatures match across tasks
   (`clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug).
4. **Living docs:** every Living docs impact entry lands in a task.
5. **Tables:** no literal `|` in any cell.

## Execution Handoff

After the self-review, proceed directly - do not ask the human to review
the plan. They gated the spec; pre-flight and per-task reviews catch plan
defects.

Announce "Plan saved to `docs/plans/<filename>.md`. Executing with
subagent-driven development." and invoke
minipowers:subagent-driven-development.
