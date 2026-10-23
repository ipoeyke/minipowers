# minipowers

A minimal fork of [obra/superpowers](https://github.com/obra/superpowers) for
Claude Code. Six skills survived the cut. The hooks, the ports to other
harnesses, and most of the process scaffolding did not survive.

Forked from upstream **v6.1.1** (commit
[`d884ae0`](https://github.com/obra/superpowers/commit/d884ae04edebef577e82ff7c4e143debd0bbec99),
July 2026). Upstream history is preserved in this repo up to that commit.

Why each skill survived (and eight didn't): see [ANALYSIS.md](ANALYSIS.md).

## Skills

| Skill | What it does |
|---|---|
| **brainstorming** | Turn an ambiguous idea into an approved design spec through one-question-at-a-time dialogue, before any code. Hands off to writing-plans. |
| **writing-plans** | Turn a spec into bite-sized tasks with exact file paths, interfaces, and test intent. Pinned requirements rather than pre-written code. Ends with a tier triage on the plan's task count. |
| **subagent-driven-development** | Execute a plan with fresh implementer subagents (one per task, or one for a small plan), adversarial review, and a fix loop in which a fresh reviewer judges every fix round. File-based handoffs (the `task-brief` and `review-package` scripts) keep the orchestrator's context small, and a progress ledger survives compaction. |
| **test-driven-development** | Red-green-refactor, with the step that matters spelled out: watch the test fail, for the right reason. Includes a debugging stop rule (three failed fixes means the problem is architectural). |
| **verification-before-completion** | No success claims without running the verification command in the same message. |
| **writing-skills** | TDD for process documentation: pressure-test a skill on subagents before trusting it. |

The flow is **brainstorming → writing-plans → subagent-driven-development**
at every size. Writing-plans sets the tier from the plan it just wrote:

- **Light** (at most 3 tasks, about 10 files): one implementer for the
  whole plan, no per-task gates, one whole-branch review, one squashed
  commit.
- **Heavy** (anything larger): one implementer and one review per task, a
  commit per task, then the whole-branch review.

Both tiers use TDD inside implementation and verification before every
completion claim. The review loop borrows from
[no-mistakes](https://github.com/kunchenguid/no-mistakes): a fresh reviewer
every round, fix-round code reviewed as unreviewed new code, findings that
enumerate every sibling site, a coverage record, and ask-user findings for
remedies that would extend the change. Specs and plans are point-in-time records that nothing
else in the repo may cite; `ARCHITECTURE.md` at the repo root is the living
description of the current system, updated by every change that alters it.
Subagent model policy is fixed: implementers run on Sonnet, task reviewers
on Opus, and the final reviewer on the strongest available model (Fable,
else Opus).

## Install

From a local clone:

```
/plugin marketplace add /path/to/minipowers
/plugin install minipowers@minipowers-dev
```

Or straight from GitHub:

```
/plugin marketplace add ipoeyke/minipowers
/plugin install minipowers@minipowers-dev
```

There is no SessionStart hook. Skills trigger through Claude Code's normal
description-based routing, or explicitly (`/minipowers:brainstorming`, etc.).

## What was cut from upstream

Eight skills, the SessionStart hook, and all the packaging for other
harnesses. Three of the eight (requesting-code-review, receiving-code-review,
systematic-debugging) were folded into the surviving skills rather than
deleted outright. The full list and per-skill rationale are in
[ANALYSIS.md](ANALYSIS.md).

## Credit

The good ideas here are Jesse Vincent's
([obra/superpowers](https://github.com/obra/superpowers), MIT). This fork
only takes things away.

Three questioning habits in the brainstorming skill (look up facts instead of
asking, attach a recommended answer to every question, resolve decisions in
dependency order) were adapted from Matt Pocock's
[grilling skill](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md) (MIT).
