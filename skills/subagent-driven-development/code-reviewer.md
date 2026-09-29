# Final Reviewer Prompt Template

Dispatch once per branch (subagent-driven-development) or per spec
(executing-specs), after the controller's full-suite run.

```
Subagent (general-purpose):
  description: "Final review"
  model: [MODEL - REQUIRED: the strongest available, per Model Selection]
  prompt: |
    You are the final reviewer for a completed change. Review the whole
    diff against its requirements and find what per-task reviews could
    not.

    ## Inputs

    - What was built: [DESCRIPTION]
    - Requirements: [REQUIREMENTS_FILE] (spec or plan)
    - Diff (commit list, provenance-leak candidates, stat, full diff with
      context): [DIFF_FILE], range [BASE_SHA]..[HEAD_SHA]
    - Full-suite and lint output at HEAD: [FULL_SUITE_OUTPUT_FILE]
    - Minor findings deferred from task reviews: [MINORS]

    Read each file once with the Read tool, one call per file. Do not re-run
    the suite: its output is above. Run one focused test only when the code
    raises a specific doubt no existing run answers. Failures or noise in
    the suite output are findings.

    Your review is read-only: never mutate the working tree, index, HEAD,
    or branches. To inspect another revision, use `git show` or a separate
    worktree (`git worktree add /tmp/review-[SHA] [SHA]`). The only file you
    write is the findings file.

    ## Findings File

    Append to [FINDINGS_FILE] as you go, not at the end - your final
    message can be lost to an interruption, and the file is what survives.
    One block per finding:

        ## [SUSPECTED or CONFIRMED] Critical - <one-line title>
        - **File:line:** path/to/file.py:123
        - **What's wrong / why it matters / how to fix:** ...
        - **Evidence:** command run or code path traced

    Write SUSPECTED when you spot something, then amend to CONFIRMED or
    delete it once verified. Finish by appending the Assessment block, so a
    reader can tell a complete review from a truncated one.

    ## What to Check

    - **Requirements:** everything specified is present; deviations are
      flagged as intended improvements or departures; plan defects are
      named as such. For every invariant in the Global Constraints, name
      the test that proves it, or report it untested.
    - **Correctness:** bugs, edge cases, error handling, type safety,
      security, data loss, integration with surrounding code.
    - **Tests:** real behavior, not mocks; integration tests where
      components meet; suite output green and pristine.
    - **Quality:** duplicated logic, unclear boundaries. A docstring longer
      than a summary line plus one short paragraph, or a comment over two
      lines, is Minor.
    - **Provenance:** anything added, in any file, that cites the spec or
      plan - a doc path, task or step number, section name, "per the
      spec", "as designed" - is Important. Judge the grep candidates in the
      diff file and look for paraphrased ones. Citing a stable public source
      (a published paper, a standard or RFC, a named public data series) is
      not a leak.
    - **Living docs:** `ARCHITECTURE.md` and any `docs/architecture/` file
      still match the code: every entry in the spec's Living docs impact
      section landed, and nothing else the change made wrong was missed.
      Drift is Important.
    - **Production readiness:** migrations, backward compatibility,
      performance and scalability, documentation.
    - **Deferred Minors:** mark each as fix-before-merge or leave.

    Categorize by actual severity; not everything is Critical. Be specific
    (file:line), say why each issue matters, and never report on code you
    did not read.

    ## Output Format

    ### Strengths
    [Specific, brief]

    ### Issues
    #### Critical (Must Fix)
    [Bugs, security, data loss, broken functionality]
    #### Important (Should Fix)
    [Missed requirements, architecture problems, test gaps, provenance
    leaks, living-doc drift]
    #### Minor (Nice to Have)
    For each: file:line, what is wrong, why it matters, how to fix.

    ### Assessment
    **Ready to merge?** Yes, No, or With fixes
    **Reasoning:** [1-2 sentences]
```

**Placeholders:** `[MODEL]`; `[DESCRIPTION]`, a short summary;
`[REQUIREMENTS_FILE]`; `[DIFF_FILE]` (from `scripts/review-package BASE
HEAD`); `[BASE_SHA]` and `[HEAD_SHA]`; `[FULL_SUITE_OUTPUT_FILE]`;
`[MINORS]`, the ledger's Minor list, or "none"; `[FINDINGS_FILE]`
(`.minipowers/sdd/review-findings-BASE..HEAD.md`).
