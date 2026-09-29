---
name: brainstorming
description: Use before creative work that is new or ambiguous - creating features, building components, or changing behavior where intent, requirements, or design are not yet pinned down. Explores user intent, requirements and design before implementation.
---

# Brainstorming Ideas Into Designs

Turn an idea into an approved design and spec through collaborative
dialogue.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it.
</HARD-GATE>

**Scale the process to the ambiguity.** A new system or an underspecified
request gets the full flow. A small, fully specified change gets a
two-sentence design and one approval question. Never skip presenting SOME
design and getting approval, and always write the spec file (a few
sentences is fine): the next skill reads it. The light path compresses the
questioning and alternatives, not the artifact.

## Checklist

Create a task for each item and complete them in order. On the light path,
items 2-3 may collapse into the design; the rest always happen.

1. **Explore context** - living docs first, then files and recent commits
2. **Ask clarifying questions** - one at a time
3. **Propose 2-3 approaches** - trade-offs and your recommendation
4. **Present the design** - get approval per round
5. **Write the spec** - `docs/specs/YYYY-MM-DD-<topic>-design.md`, not committed
6. **Self-review the spec**
7. **User reviews the written spec**
8. **Tier triage** - route to executing-specs (light) or writing-plans (heavy)

The tier triage is the terminal state. Invoke no other implementation skill.

## Living Docs

Specs and plans are point-in-time records: they overlap, go stale, and are
never edited after execution. The living docs describe the system as it is
now:

- `ARCHITECTURE.md` at the repo root: components and boundaries, data
  flow, invariants, and key decisions with their reasons. No dates, no
  history, no spec or plan references.
- An area that outgrows the root file moves to
  `docs/architecture/<area>.md`, linked from `ARCHITECTURE.md`.
- If no `ARCHITECTURE.md` exists, the first spec creates it, covering only
  the areas it touches.

Every change that alters what they describe updates them in the same work.

## Understanding the Idea

- Read the living docs, then files and recent commits. Older specs are
  history, not current truth.
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

Write to `docs/specs/YYYY-MM-DD-<topic>-design.md` unless the user prefers
another location. Do not commit it: drafts are file edits. Heavy-path
specs are committed with the plan when subagent-driven-development starts;
light-path specs land in executing-specs' single final commit.

Start with these header lines:

```
**Tier:** light or heavy (provisional until triage)
**Escalation threshold:** N files
**Supersedes:** docs/specs/<older-spec>.md (what this changes), or none
```

- **Tier** is your provisional assessment; triage confirms it. The header,
  not the conversation, is what executing-specs' entry gate reads.
- **Escalation threshold** is the Implementation notes' file count plus 2-3.
- **Supersedes** names each older spec whose decisions this one changes.
  Find them by grepping `docs/specs/` for the components and terms you
  change.

The spec must contain:

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
- **Implementation notes** (light tier only): files to create or modify,
  key interfaces, test intent, living-doc files, and per area of work one
  existing test to copy (or "none - first test for this path") plus the
  exact scoped test command. On the light path the spec is the
  implementer's whole brief.

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
10. **Tables:** no literal `|` in any cell.

## User Review Gate

Writing the design down introduces drift, and the file is what the next
skill consumes. Ask:

> "Spec written to `<path>`. Please review it and let me know if you want to make any changes before we proceed."

Apply requested changes and re-run the self-review. Proceed only on
approval.

## Tier Triage

1. Assess from concrete signals:
   - **Light:** one subsystem, roughly 1-5 files, no schema or API
     migrations, no new cross-component interfaces, about 1-3 implementer
     dispatches.
   - **Heavy:** multiple subsystems, many files, new interfaces,
     migrations, or anything needing task-by-task interface pinning.
   - **Any unresolved decision** ("TBD", "implementation must confirm", an
     open interface) forces heavy. Resolve it in the spec or route heavy.
2. State your recommendation in one line and ask one confirmation
   question. Borderline cases go heavy.
3. Update the **Tier** and **Escalation threshold** header lines and remove
   the "provisional" marker.
4. Light: invoke executing-specs. Heavy: invoke writing-plans.
