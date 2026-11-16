# Why minipowers: a critical review of superpowers

minipowers is a stripped-down fork of [obra/superpowers](https://github.com/obra/superpowers)
(forked at v6.1.1). This document records the skill-by-skill review that
decided what survived, what was cut, and why.

## The question

With today's frontier models, do we still need a process framework bolted onto
a coding agent? The models plan, debug, parallelize, and review competently on
their own, and the harnesses have absorbed several things superpowers used to
provide: native worktrees, task tracking, built-in code-review skills, and
skill routing by description.

## The answer

Partially. The framework's value concentrates in two places.

The first is structure that fights persistent model failure modes. Even
current models still (a) claim work is done without running the verification,
(b) write implementation before tests and never watch a test fail, (c) miss
their own bugs when reviewing their own work, and (d) accept review feedback
sycophantically. Skills targeting these four behaviors are worth the context
they occupy.

The second is the orchestration mechanics of subagent-driven development. A
fresh, adversarial reviewer per task, with file-based handoffs that keep the
orchestrator's context small, reliably catches correctness bugs the
implementing context cannot see. I ran a full multi-plan project (about 30
tasks) through this framework before forking, and the per-task reviewers
caught roughly ten real correctness bugs, including a lookahead bypass in a
backtest evaluator, a cross-validation ranking bug, and a trust-critical
filter that matched the wrong journal rows. None of these were caught by the
context that wrote the code.

Everything else in the plugin is either superseded by the harness or teaches
what models now do natively. The costs are real, too: per-task review roughly
doubles or triples token spend, the SessionStart hook injected about 60 lines
into every conversation, and the plan format's "complete code in every step"
mandate produced plan-authored test fixtures that were mathematically wrong
(written blind, at plan time) and had to be debugged by the implementers.

## Skill-by-skill verdicts

Verdicts are grounded in (a) the project described above, executed end-to-end
through this framework (brainstorm, spec, plans, subagent execution, reviews),
and (b) a read of every SKILL.md at v6.1.1.

| Skill | Verdict | Confidence | Rationale |
|---|---|---|---|
| subagent-driven-development | **Keep** | High | The most valuable piece of the plugin. A fresh implementer plus an adversarial reviewer per task catches real bugs that the authoring context misses; I saw this repeatedly. The `task-brief` and `review-package` scripts move artifacts between agents as files instead of pasted text, which is what keeps the orchestrator's context alive over a long plan, and the progress ledger lets a session recover after compaction. |
| verification-before-completion | **Keep** | High | Targets the most persistent LLM failure mode: claiming success without running the command. At 139 lines it is a cheap guardrail, and current models still need it. |
| writing-plans | **Keep, trimmed** | Medium | Bite-sized tasks and explicit Interfaces blocks are what make fresh-context subagent dispatch work. I dropped the "complete code in every step" mandate, though: plan-time code is written blind, and in practice it produced unsatisfiable test fixtures that implementers had to debug. Plans now carry requirements, exact signatures, and test intent, with literal code only where it is load-bearing. |
| brainstorming | **Keep, trimmed** | Medium | Structured intent-probing before design shapes projects; constraints surface before any code exists. Trimmed: the visual-companion web server is gone, and the skill now gates on new or ambiguous work instead of firing on every small feature. |
| test-driven-development | **Keep, trimmed** | Medium | Models still default to implementation-first. "Watch it fail, and fail for the right reason" catches wrong test expectations; I hit this three times in one project. The core is maybe 50 of its 371 lines, so the Iron-Law repetition and the rationalization tables went. The two durable heuristics from systematic-debugging (the three-failed-fixes stop rule, and instrumenting component boundaries before hypothesizing) moved in here. |
| writing-skills | **Cut** | Medium | Guidance for authoring skills, not part of the development flow, and nearly half of the plugin's skill text. Its bulletproofing advice (capitals, "no exceptions", tables of forbidden excuses) is the wording upstream users report as misfiring on current models. Pressure-testing a skill on subagents before trusting it still works, and it does not need a shipped skill to do. |
| requesting-code-review | **Folded into SDD** | Medium | Its only real content is a good reviewer prompt template with severity calibration and a required verdict. The template (`code-reviewer.md`) now lives inside subagent-driven-development, its only caller. |
| receiving-code-review | **Cut, core folded** | Medium | The useful core is two paragraphs: verify feedback against the codebase before implementing it, and skip the performative agreement. Those now live in SDD's review loop. Current models plus system prompts already cover the rest. |
| systematic-debugging | **Cut, two heuristics folded** | Low | Modern models root-cause well on their own. The durable twenty lines (question the architecture after three failed fixes instead of attempting a fourth; instrument component boundaries before forming hypotheses) moved into test-driven-development's bug-fix section. The other 270 lines restate what models already do. |
| using-superpowers | **Cut** | Med-High | Trigger inflation ("a 1% chance a skill applies means you MUST invoke it") plus a SessionStart hook that injected about 60 lines into every conversation. Harnesses now route skills by description natively, so this was replaced by nothing and the hook was deleted. |
| executing-plans | **Cut** | High | Its own text says to prefer subagent-driven-development whenever subagents are available, and in Claude Code they always are. |
| dispatching-parallel-agents | **Cut** | High | The harness's own Agent-tool documentation already teaches parallel dispatch and context isolation. The skill adds a small decision tree on top. |
| using-git-worktrees | **Cut** | High | Superseded by native harness worktrees (worktree-isolated subagents and equivalent tools). 202 lines of obsolete mechanics. |
| finishing-a-development-branch | **Cut** | Medium | A structured merge/PR questionnaire. In live use I declined it every time it fired. One line inside SDD replaced it: push the branch and open a draft PR when the plan is done. |

## What else was removed

Everything not needed to run the surviving skills in Claude Code:

- **Other-harness ports**: `.codex-plugin/`, `.cursor-plugin/`, `.opencode/`,
  `.kimi-plugin/`, `.pi/`, `.agents/`, `gemini-extension.json`, `GEMINI.md`,
  `AGENTS.md`, `package.json`, and the sync/packaging scripts under `scripts/`.
- **Hooks**: the SessionStart injection (`hooks/`); see using-superpowers above.
- **Repo scaffolding**: `tests/` (mostly hook and port test harnesses),
  `docs/`, `assets/`, `.github/`, `CODE_OF_CONDUCT.md`, `RELEASE-NOTES.md`,
  `CLAUDE.md`, `.pre-commit-config.yaml`, `.version-bump.json`.
- **Brainstorming's visual companion** (a web server plus HTML template).

The result keeps most of the value I actually observed, at a small fraction of
the original's context cost, with a single-harness surface.

## Later alignment

Three later rounds reshaped the flow. Only the third changed a verdict:
writing-skills, kept at the fork and shown above as cut. The
first routed every change through writing-plans and let the plan's task
count pick a light or heavy execution tier, and borrowed the review-loop
discipline of no-mistakes: a fresh reviewer every round, fix-round code
treated as unreviewed, findings that enumerate every sibling site. The
second aligned the artifacts with Anthropic's AI-native SDLC playbook: a
committed `intent.md`, `spec.md`, and `plan.md` per change under
`docs/changes/`, a human approval on the plan, amendments appended to the
plan as the change is built, and a draft pull request rather than a local
merge as the terminal state. It also added the plugin's only hook: a
PreToolUse guard that makes test files read-only during fix rounds, inert
otherwise and free of context cost, unlike the SessionStart hook that was
cut.

The third round answered reports from upstream users, read 2026-11-17:
issues [#2377](https://github.com/obra/superpowers/issues/2377) and
[#2423](https://github.com/obra/superpowers/issues/2423) (shouted wording
and narration limits misfire on current models),
[#895](https://github.com/obra/superpowers/issues/895) (the test-first
ceremony repeated in every plan task), and an r/ClaudeCode thread,
[PSA: Superpowers skill with opus ruined my codebase](https://www.reddit.com/r/ClaudeCode/comments/1xwmeln/)
(suites inflated with tests that pin implementation or never fail). It
cut writing-skills, which guided work on this repository, not the
development flow, and was nearly half of the plugin's skill text; cut
verification-before-completion to its rule and
evidence table; stated the TDD rule once and scoped it to behavior;
removed the per-task test-first steps from plans; dropped the narration
limit from subagent-driven-development; and gave both reviewers a check
that each new test can fail for a bug, with deletion as the fix.

## Credit

Most of the good ideas here are Jesse Vincent's
([obra/superpowers](https://github.com/obra/superpowers)). This fork takes
most of the original away; what it adds is adapted from the other sources
credited in the [README](README.md#credit).
