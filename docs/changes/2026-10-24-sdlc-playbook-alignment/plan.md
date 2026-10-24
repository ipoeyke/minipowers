# SDLC Playbook Alignment Implementation Plan

**Spec:** spec.md
**Tier:** light

**Goal:** Make minipowers' artifacts, gates, and terminal state match the
AI-native SDLC playbook.

## Files that change
- `skills/brainstorming/SKILL.md`: open the change, capture intent, policy skills, spec sections, commit on approval
- `skills/writing-plans/SKILL.md`: read-only rule, summary sections, Amendments, approval gate, commit
- `skills/subagent-driven-development/SKILL.md`: kickoff without docs commit, Plan Amendments, fix-round marker, PR wrap-up, ledger scope
- `skills/subagent-driven-development/{implementer,fixer}-prompt.md`: amendment block, test rule, provenance paths
- `skills/subagent-driven-development/{code,task}-reviewer*.md`: REVIEW.md, compliance pass, nit cap, CLAUDE.md checks
- `skills/subagent-driven-development/scripts/{task-brief,review-package}`: provenance paths
- `README.md`, `ANALYSIS.md`, `.claude-plugin/*.json`

## Order of work
1. Task 1: artifact chain and commits (brainstorming, writing-plans, SDD kickoff and squash, scripts)
2. Task 2: plan lifecycle (approval gate, Amendments, ledger scope)
3. Task 3: review and PR (REVIEW.md, test rule, marker, PR body, README, ANALYSIS)

## Risks
A controller following the old flow from memory commits nothing until
kickoff and finds the clean-tree check failing. Mitigated by the kickoff
text naming the plan commit as the base.

## Proof
Fresh-eyes coherence review of the six skill files finds no contradictions
or dangling references. Grep for `docs/specs`, `docs/plans`, and "merge
locally" across `skills/` and `README.md` returns only the intentional
legacy mentions: the provenance grep pattern in `scripts/review-package`
and brainstorming's note on older repos.

## Amendments
- Tasks 1-3 were executed in one pass by the controller rather than
  dispatched, since the change edits the skills that define dispatch.
