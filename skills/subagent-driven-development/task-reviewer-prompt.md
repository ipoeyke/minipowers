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

    ## The Report Is Unverified

    Treat the report as claims to verify against the diff. Design
    rationales in it ("kept it simple deliberately") are the implementer
    grading their own work and never downgrade a finding.

    ## Tests

    The report carries the implementer's test evidence; do not re-run the
    suite. Run one focused test only when the code raises a specific doubt
    no existing run answers - never a package-wide suite, race detector
    run, or repeated loop. If heavier validation seems warranted, recommend
    it instead. If you cannot run commands, name the test you would run. Warnings or noise in reported test
    output are findings.

    ## Part 1: Spec Compliance

    - **Missing:** requirements skipped or claimed without implementing
    - **Extra:** features not requested, over-engineering
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
    - **Provenance:** anything added, in any file or commit subject, that
      cites the spec or plan - a doc path, task or step number, section
      name, "per the plan", "as designed" - is Important. Judge each grep
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

    Cite file:line for every finding and for every check you would
    otherwise answer with a bare "yes". Begin directly with the spec
    verdict: no preamble, no narration, no closing summary.

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
    For each: file:line, what is wrong, why it matters, how to fix if not
    obvious.

    ### Assessment
    **Task quality:** Approved, or Needs fixes
    **Reasoning:** [1-2 sentences]
```

**Placeholders:** `[MODEL]`; `[BRIEF_FILE]` (from `scripts/task-brief`,
the same file the implementer read); `[REPORT_FILE]`; `[DIFF_FILE]` (from
`scripts/review-package BASE HEAD`); `[BASE_SHA]` and `[HEAD_SHA]`;
`[GLOBAL_CONSTRAINTS]` copied verbatim from the plan's Global Constraints
or the spec - exact values, formats, and stated relationships, not process
rules.

A fix dispatch can address spec gaps and quality findings together; the
re-review covers both verdicts.
