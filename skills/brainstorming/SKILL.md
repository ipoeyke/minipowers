---
name: brainstorming
description: Use before creative work that is new or ambiguous - creating features, building components, or changing behavior where intent, requirements, or design are not yet pinned down. Explores user intent, requirements and design before implementation.
---

# Brainstorming Ideas Into Designs

Turn an idea into a committed intent and an approved, committed spec
through collaborative dialogue. The two files start the change's artifact
chain: `intent.md`, `spec.md`, `plan.md`, the diff, the PR.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. Creating the branch and committing intent.md and spec.md are not implementation actions.
</HARD-GATE>

**Scale the process to the ambiguity.** A new system or an underspecified
request gets the full flow. A small, fully specified change gets a
two-sentence design and one approval question. Never skip presenting SOME
design and getting approval, and always write the spec file (a few
sentences is fine): the next skill reads it. The short path compresses the
questioning and alternatives, not the artifact.

## Checklist

Create a task for each item and complete them in order. On the short path,
items 2-3 may collapse into the design; the rest always happen.

1. **Open the change** - branch and `docs/changes/<id>/`
2. **Capture intent** - `intent.md` in the user's words, confirm, commit
3. **Explore context** - living docs first, then files and recent commits
4. **Ask clarifying questions** - one at a time, intent's open questions first
5. **Propose 2-3 approaches** - trade-offs and your recommendation
6. **Present the design** - get approval per round
7. **Write the spec** - `docs/changes/<id>/spec.md`
8. **Self-review the spec**
9. **User reviews the written spec** - approval commits it
10. **Hand off** - invoke writing-plans

Invoking writing-plans is the terminal state. Invoke no other implementation
skill: writing-plans sizes the work and picks the execution tier.

## Opening the Change

The change id is `YYYY-MM-DD-<topic>`; every artifact lives in
`docs/changes/<id>/`. Before writing anything, make sure you are on this
change's branch: on main/master, create `<topic>` from it; on another
branch, ask once whether this change belongs there or on a new branch from
main. Every artifact commit and every code commit lands there, so the PR
carries the whole chain. Never commit a change's artifacts to main.

## Capturing Intent

Write `docs/changes/<id>/intent.md` before exploring or asking anything,
from what the user said, in their terms. If the user points at an existing
`intent.md` (written by someone else, or by an incident process), read it
instead of writing one.

```
# Intent: <topic>
Author: <git user.name>. Status: draft.

## Problem
## Proposed outcome
## Affected users and systems
## Constraints
## Open questions
```

Each section is one to three sentences. Everything the user left unclear
goes under Open questions verbatim; the questioning phase works that list
down first. Ask once: "Intent captured at `<path>`. Correct?" Apply
corrections, set `Status: accepted`, commit `docs: intent for <topic>`.
Intent is frozen from here; what changes later changes the spec.

## Living Docs

Intent, spec, and plan are the change's record: the plan is amended while
the change is built, and all three freeze when it merges. They overlap and
go stale by design. The living docs describe the system as it is now:

- `ARCHITECTURE.md` at the repo root: components and boundaries, data
  flow, invariants, and key decisions with their reasons. No dates, no
  history, no spec or plan references.
- An area that outgrows the root file moves to
  `docs/architecture/<area>.md`, linked from `ARCHITECTURE.md`.
- If no `ARCHITECTURE.md` exists, the first spec creates it, covering only
  the areas it touches.

Every change that alters what they describe updates them in the same work.

## Understanding the Idea

- Read the living docs, then files and recent commits. Older changes
  under `docs/changes/` are history, not current truth.
- If the request spans multiple independent subsystems, say so before
  detailed questions and help decompose it into sub-projects, each with
  its own spec and implementation cycle. Brainstorm the first one.
- Aim at purpose, constraints, and success criteria.
- Look up anything the environment can answer (files, git, docs, running
  a command). Ask only about decisions and preferences that are the
  user's.
- One question per message, multiple choice where possible, each with your
  recommended answer and why, so confirming takes one word.
- Ask in dependency order: settle upstream decisions before those that
  hinge on them.

## Approaches and Design

- Propose 2-3 approaches with trade-offs, leading with your recommendation.
  YAGNI: remove features the goal does not need.
- Before designing, list the skills available in this repo and its
  plugins whose description reads as policy: security, compliance, UX,
  brand, API or data standards. Load the ones the change touches and
  design within them. Where the design cannot satisfy one, or two
  conflict, say so in the design round and record it in the spec's Areas
  of concern.
- Present the design once you understand what you're building, covering
  architecture, components, data flow, error handling, and testing. Scale
  each section to its complexity (a few sentences to 200-300 words).
- Present straightforward sections together in one brief round; give a
  section its own round only when it holds a decision for the user. If the
  user approves several rounds in a row without changes, batch the rest.
- Design units with one clear purpose and well-defined interfaces, each
  understandable and testable without reading its internals. A file
  growing large is a sign it does too much.
- In existing codebases, follow established patterns. Include targeted
  improvements where existing problems affect the work; propose no
  unrelated refactoring.

## Writing the Spec

Write to `docs/changes/<id>/spec.md`. Drafts are file edits; the file is
committed once, when the user approves it.

Start with these header lines:

```
**Intent:** intent.md
**Supersedes:** docs/changes/<older-id>/spec.md (what this changes), or none
```

Supersedes names each older spec whose decisions this one changes. Find
them by grepping `docs/changes/` (and `docs/specs/`, where older repos kept
them) for the components and terms you change.

The spec must contain:

- **Open questions from intent**: each one, answered with the answer, or
  carried forward with why it can wait and a statement that its answer
  cannot change the plan. A carried question that could change the plan
  is unresolved: resolve it.
- **Areas of concern**: the policy skills consulted by name, then one
  entry per place the design cannot satisfy a policy or two policies
  conflict: the policy, the conflict, the proposed resolution, who owns
  the call. "None" is valid only after the consulted list.

- **Every decision from the conversation**: the chosen approach, each
  rejected alternative with its reason, preferences, definitions, and
  answers. Conversation memory does not survive compaction.
- **A reason for each non-obvious value or constraint**, in one domain-terms
  clause or as a stable public source (a published paper, a standard or
  RFC, a named public data series). Implementers may not cite the spec in
  code, so this is what ends up in the comment.
- **Limitations**: every deliberate simplification, its cost, and why the
  cost is acceptable. An unwritten simplification reads as an oversight.
- **Living docs impact**: which sections of the living docs change and what
  they will say, or "none".
- **No unresolved decision**: no "TBD", "implementation must confirm", or
  open interface. The plan pins what the spec leaves open only by guessing.

Markdown tables: no cell may contain a literal `|`, not even inside
backticks - GitHub-flavoured markdown splits cells on it first. Write
closed values as separate code spans (`` `gain`, `loss`, `flat` ``) and
unions with "or" (`int or None`).

## Spec Self-Review

Check with fresh eyes and fix inline:

1. **Placeholders:** no "TBD", "TODO", or vague requirements.
2. **Consistency:** no contradicting sections; architecture matches features.
3. **Scope:** focused enough for one plan, or needs decomposition.
4. **Ambiguity:** no requirement readable two ways.
5. **Rationale:** every non-obvious value has a reason or public source.
6. **Evidence (quantitative specs):** every numeric acceptance criterion
   has evidence it is reachable or a "to be probed at plan time" marker;
   every sourced value names a retrievable source. If not, ask the user
   "where is the reference?" before presenting the spec.
7. **Decisions:** walk back through the questions and rejected approaches;
   every one appears.
8. **Limitations:** every simplification listed with cost and justification.
9. **Living docs and Supersedes:** every section this change makes wrong is
   named, and every older spec it overrides.
10. **Intent:** every open question from `intent.md` is answered or carried
    forward; the policy skills consulted are named.
11. **Tables:** no literal `|` in any cell.

## User Review Gate

Writing the design down introduces drift, and the file is what the next
skill consumes. Ask:

> "Spec written to `<path>`. Please review it and let me know if you want to make any changes before we proceed."

Apply requested changes and re-run the self-review. On approval, commit
`docs: spec for <topic>`, then invoke writing-plans. Every size of change
goes through it: the plan's task count, not a guess at spec time, decides
whether execution runs light (one implementer for the whole plan) or heavy
(one per task).
