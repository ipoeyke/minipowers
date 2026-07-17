# Why minipowers: a critical review of superpowers

minipowers is a stripped-down fork of [obra/superpowers](https://github.com/obra/superpowers)
(forked at v6.1.1). This document records the skill-by-skill review that decided
what survived, what was cut, and why.

## The question

With today's frontier models, do we still need a process framework bolted onto a
coding agent? The models plan, debug, parallelize, and review competently on
their own, and the harnesses have absorbed several things superpowers used to
provide (native worktrees, task tracking, built-in code-review skills,
skill routing by description).

## The answer

Partially. The framework's value concentrates in exactly two places:

1. **Structure that fights persistent model failure modes.** Even current
   models still (a) claim work is done without running the verification,
   (b) write implementation before tests and never watch a test fail,
   (c) miss their own bugs when reviewing their own work, and
   (d) accept review feedback sycophantically. Skills targeting these four
   behaviors earn their context window.
2. **The orchestration mechanics of subagent-driven development.** A fresh,
   adversarial reviewer per task — with file-based handoffs so the
   orchestrator's context stays small — reliably catches correctness bugs the
   implementing context cannot see. In one multi-plan project run through this
   framework (~30 tasks), per-task reviewers caught roughly ten real
   correctness bugs, including a lookahead bypass in a backtest evaluator, a
   cross-validation ranking bug, and a trust-critical filter that matched the
   wrong journal rows. None were caught by the authoring context.

Everything else in the plugin is either superseded by the harness, teaches what
models now do natively, or is ceremony. There is also a real cost side:
per-task review roughly doubles-to-triples token spend, the SessionStart hook
injected ~60 lines into every conversation, and the plan format's
"complete code in every step" mandate produced plan-authored test fixtures that
were mathematically wrong (written blind, at plan time) and had to be debugged
by implementers.

## Skill-by-skill verdicts

Verdicts are grounded in (a) a full project executed end-to-end through this
framework (brainstorm → spec → plans → subagent-driven execution → reviews),
and (b) a read of every SKILL.md at v6.1.1.

| Skill | Verdict | Confidence | Rationale |
|---|---|---|---|
| subagent-driven-development | **Keep** | High | The crown jewel. Fresh implementer + adversarial reviewer per task catches real bugs the author-context misses (observed repeatedly). The `task-brief`/`review-package` scripts move artifacts as files instead of pasted text, which is what keeps the orchestrator's context alive over long plans. The progress ledger survives compaction. |
| verification-before-completion | **Keep** | High | Targets the single most persistent LLM failure mode: claiming success without running the command. Cheap (139 lines), pure guardrail, still needed. |
| writing-plans | **Keep, trimmed** | Medium | Bite-sized tasks + explicit Interfaces blocks are what make fresh-context subagent dispatch work. But the "complete code in every step" mandate is dropped: plan-time code is written blind, and in practice produced unsatisfiable test fixtures that implementers had to debug. Plans now carry requirements, exact signatures, and test intent — code only where it is genuinely load-bearing. |
| brainstorming | **Keep, trimmed** | Medium | Structured intent-probing before design genuinely shapes projects (constraints surface before code exists). Trimmed: the visual-companion web server is gone; gate the skill to genuinely new/ambiguous work rather than every small feature. |
| test-driven-development | **Keep, trimmed** | Medium | Models still default to implementation-first. "Watch it fail, and fail for the RIGHT reason" catches wrong test expectations — observed three times in one project. Core value is ~50 of its 371 lines; the Iron-Law repetition and rationalization tables are cut. The two durable heuristics from systematic-debugging (3-failed-fixes stop rule, instrument component boundaries) folded in here. |
| writing-skills | **Keep** | Low-Med | Only valuable if you author your own skills (this user does). TDD-for-documentation — pressure-test a skill on subagents before trusting it — is sound method. |
| requesting-code-review | **Folded into SDD** | Medium | Its only real content is a good reviewer prompt template (severity calibration, clear verdict). The template (`code-reviewer.md`) now lives inside subagent-driven-development, which was its only caller. |
| receiving-code-review | **Cut, one paragraph folded** | Medium | The anti-sycophancy core ("verify feedback against the codebase before implementing; no performative agreement") is two paragraphs of value, now inside SDD's review loop. Current models plus system prompts already push the rest. |
| systematic-debugging | **Cut, two heuristics folded** | Low | Modern models root-cause well natively. The durable ~20 lines — "3 failed fixes means question the architecture, not attempt fix #4" and "instrument component boundaries before hypothesizing" — moved into test-driven-development's bug-fix section. The other 270 lines restate what models do. |
| using-superpowers | **Cut** | Med-High | Trigger inflation ("1% chance a skill applies → MUST invoke") plus a SessionStart hook injecting ~60 lines into every conversation. Harnesses now route skills by description natively. Replaced by nothing; the hook is deleted. |
| executing-plans | **Cut** | High | Its own text says to prefer subagent-driven-development whenever subagents exist. They always do in the target harness. Dead branch. |
| dispatching-parallel-agents | **Cut** | High | Harness Agent-tool documentation already teaches parallel dispatch and context isolation. The skill adds a trivial decision tree. |
| using-git-worktrees | **Cut** | High | Superseded by native harness worktrees (worktree-isolated subagents, EnterWorktree-style tools). 202 lines of obsolete mechanics. |
| finishing-a-development-branch | **Cut** | Medium | Merge/PR option ceremony; in live use its structured question was declined every time it fired. Replaced with one line inside SDD: ask the human about branch disposition when the plan is done. |

## What else was removed

Everything not needed to run these six skills in Claude Code:

- **Other-harness ports**: `.codex-plugin/`, `.cursor-plugin/`, `.opencode/`,
  `.kimi-plugin/`, `.pi/`, `.agents/`, `gemini-extension.json`, `GEMINI.md`,
  `AGENTS.md`, `package.json`, and the sync/packaging scripts under `scripts/`.
- **Hooks**: the SessionStart injection (`hooks/`) — see using-superpowers above.
- **Repo scaffolding**: `tests/` (mostly hook/port test harnesses), `docs/`,
  `assets/`, `.github/`, `CODE_OF_CONDUCT.md`, `RELEASE-NOTES.md`,
  `CLAUDE.md`, `.pre-commit-config.yaml`, `.version-bump.json`.
- **Brainstorming's visual companion** (web server + HTML template).

Result: ~85% of the observed value at roughly 30% of the context cost, with a
single-harness (Claude Code) surface.

## Credit

All of the good ideas here are Jesse Vincent's ([obra/superpowers](https://github.com/obra/superpowers)).
This fork just subtracts.
