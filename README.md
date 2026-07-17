# minipowers

A minimal fork of [obra/superpowers](https://github.com/obra/superpowers) for
Claude Code. Six skills survived the cut. The hooks, the ports to other
harnesses, and most of the process scaffolding did not.

Forked from upstream **v6.1.1** (commit
[`d884ae0`](https://github.com/obra/superpowers/commit/d884ae04edebef577e82ff7c4e143debd0bbec99),
July 2026). Upstream history is preserved in this repo up to that commit.

Why each skill survived (and eight didn't): see [ANALYSIS.md](ANALYSIS.md).

## Skills

| Skill | What it does |
|---|---|
| **brainstorming** | Turn an ambiguous idea into an approved design spec through one-question-at-a-time dialogue, before any code. |
| **writing-plans** | Turn a spec into bite-sized tasks with exact file paths, interfaces, and test intent. Pinned requirements rather than pre-written code. |
| **subagent-driven-development** | Execute a plan with a fresh implementer subagent per task, an adversarial reviewer per task, and a whole-branch review at the end. File-based handoffs (the `task-brief` and `review-package` scripts) keep the orchestrator's context small, and a progress ledger survives compaction. |
| **test-driven-development** | Red-green-refactor, with the step that matters spelled out: watch the test fail, for the right reason. Includes a debugging stop rule (three failed fixes means the problem is architectural). |
| **verification-before-completion** | No success claims without running the verification command in the same message. |
| **writing-skills** | TDD for process documentation: pressure-test a skill on subagents before trusting it. |

The flow is **brainstorming → writing-plans → subagent-driven-development**,
with TDD inside each task and verification before every completion claim.

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
