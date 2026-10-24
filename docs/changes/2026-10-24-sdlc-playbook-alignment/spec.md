**Supersedes:** docs/changes/2026-07-26-two-tier-workflow/spec.md (spec and plan locations, commit timing, terminal state)

# SDLC playbook alignment

## Open questions from intent
- Where do per-change artifacts live? Answered: `docs/changes/<YYYY-MM-DD-topic>/`
  holding `intent.md`, `spec.md`, `plan.md`. The playbook names an
  `intent/` folder with spec committed beside intent and gives no home for
  the plan; `docs/changes/` keeps the trio together and away from the living
  docs. Rejected: `docs/<feature>/` (mixes point-in-time records with living
  docs) and a literal `intent/` (odd once it holds specs and plans).

## Areas of concern
Consulted: no policy skills exist in this repo. None.

## Decisions
1. Intent is always written, even when the user typed the idea: the
   playbook's primary route is a person brainstorming with Claude and
   writing the result down. Ten lines, one confirmation, one commit.
2. Spec gains Open questions from intent and Areas of concern, the latter
   filled by consulting the repo's policy skills.
3. Plan approval returns as a one-word gate on a summary (files, order,
   risks, proof). Planning is read-only apart from the plan file.
4. The plan stays live through Build: deviations and human rulings are
   appended to an Amendments section in the same commit as the code.
5. Each stage commits its artifact; the light tier squashes only the
   implementation commits.
6. The controller never merges. It pushes and opens a PR whose body carries
   intent, changes, deviations, review, verification, and decisions.
7. The final reviewer runs the repo's REVIEW.md passes when present, has an
   explicit compliance pass against spec and plan, caps Minors at five, and
   proposes CLAUDE.md corrections.
8. Fixers and implementers never edit an existing test to make it pass; a
   fix-round marker file lets a consuming repo enforce it with a hook.
9. The ledger records progress only; decisions live in plan Amendments and
   the PR body.

## Limitations
- Plan approval adds one question per change. Cost accepted: the playbook
  requires an accepted plan, and the question is one word.
- The test-protection hook ships as README guidance, not in the plugin,
  because minipowers deliberately ships no hooks. Cost: advisory only
  unless the consuming repo installs it.
- No verifier subagent that runs the app, no CI evals for skill changes.
  Both optional in the playbook; deferred.
- No ARCHITECTURE.md is created, although brainstorming says the first
  spec creates one. This repo is markdown skills with no runtime
  components; README and ANALYSIS.md are its living description.
- This change's own plan predates the writing-plans template it
  introduces: no Task blocks, so `scripts/task-brief` cannot split it. It
  was executed in one pass by the controller.

## Living docs impact
None: this repo has no ARCHITECTURE.md; README and ANALYSIS.md describe the
flow and are updated in this change.
