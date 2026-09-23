# Plan Writer Prompt Template

Use this template to dispatch the plan writer once a spec routes to the
heavy tier. Planning runs in a fresh subagent so its codebase exploration,
feasibility probes, and plan drafts stay out of the controller's context,
which has to last through the whole execution run. A plan writer that
cannot work from the spec alone has found a gap in the spec.

```
Subagent (general-purpose):
  description: "Write implementation plan for [FEATURE]"
  model: opus  # REQUIRED - an omitted model inherits the session's model
  prompt: |
    Use the minipowers:writing-plans skill to write the implementation
    plan for this spec: [SPEC_FILE]

    Save the plan to: [PLAN_FILE]
    Work from: [REPO_DIR]

    The spec is your only source of intent. Every decision made during
    design is written in it; you have no access to that conversation.
    Where the spec is silent on a detail, choose the reading that best
    fits its stated intent and record it as an assumption - never fill a
    gap silently.

    If the spec leaves open a decision that would change the plan's
    structure (task boundaries, interfaces, a binding constraint), stop
    and report NEEDS_CONTEXT with the question and your recommended
    answer instead of planning around it.

    Do not commit the plan or the spec. Do not start execution.

    Report back with ONLY:
    - **Status:** DONE | NEEDS_CONTEXT
    - The plan path and its task count
    - **Assumptions:** each place the spec was silent, the reading you
      chose, and why. "None" if there were none.
    - **Feasibility probes:** each enforced threshold, the probe you ran,
      its observed false-alarm rate, and the value you pinned. "None" if
      the plan enforces no thresholds.
    - For NEEDS_CONTEXT: the question and your recommendation
```

**Placeholders:**
- `[FEATURE]` - short feature name
- `[SPEC_FILE]` - REQUIRED: the approved spec path
- `[PLAN_FILE]` - `docs/plans/YYYY-MM-DD-<feature-name>.md` unless the user
  prefers another location
- `[REPO_DIR]` - the working directory

Pass nothing else: no conversation summary, no pasted spec text. If a
decision is missing from the spec, write it into the spec before
dispatching.

**Handling the return:**
- **NEEDS_CONTEXT:** ask the human, write the answer into the spec, then
  resume the plan writer (SendMessage if it is still alive, otherwise
  re-dispatch). The spec stays the single source of intent.
- **DONE:** invoke minipowers:subagent-driven-development and carry the
  Assumptions and Feasibility probes lists into its pre-flight review.
