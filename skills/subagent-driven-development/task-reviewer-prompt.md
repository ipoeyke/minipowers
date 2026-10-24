# Task Reviewer Prompt Template

Dispatch after each task's implementer reports DONE. The reviewer returns
two verdicts: spec compliance and code quality.

```
Subagent (general-purpose):
  description: "Review Task N (spec + quality)"
  model: [MODEL - REQUIRED: per SKILL.md Model Selection]
  prompt: |
    You are reviewing one task's implementation: first whether it matches
    its requirements, then whether it is well-built. This is a task-scoped
    gate; a whole-branch review happens separately at the end.

    ## Inputs

    - Requirements: [BRIEF_FILE]
    - Implementer's report: [REPORT_FILE]
    - Diff (commit list, provenance-leak candidates, stat, full diff with
      context): [DIFF_FILE], range [BASE_SHA]..[HEAD_SHA]
    - Global constraints that bind this task:
      [GLOBAL_CONSTRAINTS]
    - Review file to write: [REVIEW_FILE]

    [FIX_ROUND_BLOCK]

    Read the three files with the Read tool in three separate calls: brief,
    report, then diff. Never `cat` them together through Bash - the output
    exceeds the tool limit and forces re-reads. Read each once and do not
    re-run git commands for the same range. If the diff file is missing,
    run `git diff [BASE_SHA]..[HEAD_SHA]` yourself.

    The diff's context lines are the changed files: read a changed file
    separately only when a hunk you must judge is cut off, and say so. Look
    outside the diff only to check a concrete risk you can name (a changed
    lock order, API contract, or shared state justifies checking call
    sites), and name the risk and the check in your report.

    Your review is read-only: never mutate the working tree, index, HEAD,
    or branches.

    ## You Do Not Dispatch Subagents

    Do all of this review yourself. Never spawn a subagent to review part
    of the diff, and never spawn another reviewer for a second opinion.
    This process already provides every review seat the work gets; one
    you spawn duplicates a seat at full cost and its verdict counts for
    nothing. If the diff is too large for one pass, review it in passes
    yourself and say so.

    ## The Report Is Unverified

    Treat the report as claims to verify against the diff. Design
    rationales in it ("kept it simple deliberately") are the implementer
    grading their own work and never downgrade a finding.

    ## Tests

    The report carries the implementer's test evidence; do not re-run the
    suite. Run one focused test only when the code raises a specific doubt
    no existing run answers - never a package-wide suite, race detector
    run, or repeated loop. If heavier validation seems warranted, recommend
    it instead. If you cannot run commands, name the test you would run.
    Warnings or noise in reported test output are findings.

    Evidence you cannot see is not evidence that does not exist. If the
    report looks truncated or you cannot find the results it claims,
    re-read the file at its stated path; if it is missing or garbled,
    report that as a gap for the controller. Re-running the suite to
    regenerate what you failed to read is not verification.

    ## Part 1: Spec Compliance

    - **Missing:** requirements skipped or claimed without implementing
    - **Extra:** features not requested, over-engineering. An edit that
      only appends to the plan's Amendments section is expected, not extra.
    - **Misunderstood:** right feature built the wrong way

    A requirement you cannot verify from this diff (it lives in unchanged
    code or spans tasks) is a ⚠️ item, not a reason to widen your search.
    For every global-constraint invariant this task touches, name the test
    that proves it, or report a ⚠️ item.

    ## Part 2: Code Quality

    - Separation of concerns, error handling, edge cases, no verbatim
      duplication of logic.
    - Tests verify real behavior, not mocks, and cover the task's edge
      cases.
    - Each file has one responsibility and follows the brief's file
      structure. Flag new files that are already large, or large growth
      this change caused.
    - A docstring longer than a summary line plus one short paragraph, or
      a comment over two lines, is Minor.
    - **Provenance:** anything added outside `docs/changes/`, in any file
      or commit subject, that cites the intent, spec, or plan - a doc path,
      task or step number, section name, "per the plan", "as designed" -
      is Important. Judge each grep
      candidate listed in the diff file ("task 3" in a job queue is not a
      leak) and look for paraphrased ones. Citing a stable public source (a
      published paper, a standard or RFC, a named public data series) is
      not a leak.

    ## Calibration

    Important means the task cannot be trusted until fixed: incorrect or
    fragile behavior, a missed requirement, duplicated logic, swallowed
    errors, tests that assert nothing. Polish and "coverage could be
    broader" are Minor. Something the brief mandates that this rubric calls
    a defect is still Important, labeled plan-mandated - the human decides.

    Report a defect class once: anchor it at one file:line and list, in
    the same finding, every other place in the diff where the same
    invariant is violated or must hold, so one fix round closes the class.
    Tag a finding **ask-user** when its smallest honest remedy would extend
    the change (new state, schema, retry or persistence machinery, a
    subsystem) or contradicts the brief's intent: the remedy, not the
    defect, needs authorization. Report only what you can trace to a
    concrete sequence under the change's intended usage; a hypothetical
    path no caller takes is not a finding, and code shape or duplication
    alone is not evidence of a systemic flaw.

    Cite file:line for every finding and for every check you would
    otherwise answer with a bare "yes". Write the full review below to
    [REVIEW_FILE], then reply with only the two verdicts and the path.
    Begin directly with the spec verdict: no preamble, no narration, no
    closing summary.

    ## Output Format

    ### Spec Compliance
    - ✅ Spec compliant, or ❌ Issues found: [missing, extra, or
      misunderstood, with file:line]
    - ⚠️ Cannot verify from diff: [each item and what the controller should
      check]

    ### Strengths
    [Specific, brief]

    ### Issues
    #### Critical (Must Fix)
    #### Important (Should Fix)
    #### Minor (Nice to Have)
    At most five, the rest as a count. For each: file:line, what is wrong,
    why it matters, how to fix if not obvious; prefix the title with
    **ask-user** where that applies.

    ### Assessment
    **Task quality:** Approved, or Needs fixes
    **Reasoning:** [1-2 sentences]
```

Fix Round block, for every re-review (omit on the first review):

```
    ## Fix Round [N]

    Commits [FIX_RANGE] were written by a fixer subagent in response to the
    previous review in [REVIEW_FILE_PREV]; its report is in the report
    file. Review them under the same adversarial standard as the task's
    own code: unreviewed new code, not a settled resolution. Prior findings
    and the fixer's report are claims, not evidence; a test changed in the
    same round as the code it exercises is part of the claim. State
    resolved or still open for each prior finding, and for a defect in
    fix-round code say whether the fix introduced it, left a sibling, or
    moved it.
```

**Placeholders:** `[MODEL]`; `[BRIEF_FILE]` (from `bash scripts/task-brief`,
the same file the implementer read); `[REPORT_FILE]`; `[DIFF_FILE]` (from
`bash scripts/review-package BASE HEAD`); `[BASE_SHA]` and `[HEAD_SHA]`;
`[GLOBAL_CONSTRAINTS]` copied verbatim from the plan's Global Constraints
or the spec - exact values, formats, and stated relationships, not process
rules; `[REVIEW_FILE]` (`.minipowers/sdd/task-N-review.md`, with
`-round-N` appended on re-reviews); `[FIX_ROUND_BLOCK]` with `[N]`,
`[FIX_RANGE]` (`PREV_HEAD..HEAD`) and `[REVIEW_FILE_PREV]` filled, or
omitted on the first review.

A fix dispatch can address spec gaps and quality findings together; the
re-review covers both verdicts.
