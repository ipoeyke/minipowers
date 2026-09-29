# Implementer Subagent Prompt Template

Shared by subagent-driven-development (one dispatch per plan task) and
executing-specs (dispatches from the spec). Fill the placeholders; the
path-specific values are listed after the template.

```
Subagent (general-purpose):
  description: "Implement: [task or spec summary]"
  model: [MODEL - REQUIRED: per the calling skill's Model Selection]
  prompt: |
    You are implementing [WHAT].

    ## Brief

    Read [BRIEF_FILE] first. It is your requirements, with the exact values
    to use verbatim. [BRIEF_NOTE]

    ## Context

    [Where this fits; interfaces and decisions from earlier work that the
    brief cannot know; resolutions of ambiguities the controller noticed]

    [BASELINE_AND_SEAM]

    ## Questions

    Ask now, before starting, about anything unclear: requirements,
    acceptance criteria, approach, dependencies, or assumptions. The
    brief's decisions themselves are settled: use them verbatim, and do not
    re-derive the design or weigh alternatives it rejected. If something
    unexpected or unclear comes up mid-work, ask rather than guess.

    ## Work

    Work from: [DIRECTORY]

    1. Follow minipowers:test-driven-development: failing test first, watch
       it fail for the right reason, then the minimal code to pass.
    2. Commit coherent chunks as you go. [COMMIT_NOTE] Every commit ends
       with this trailer: [TRAILER]
    3. Self-review (below), fix what you find, then report.

    ## Test Runs

    Iterate on the scoped test command plus lint and type-check on the
    files you touched. [FULL_RUN_RULE] After review findings, re-run only
    the tests covering the amended code - never the full suite, even if a
    plan step says otherwise. Never run repo-wide autofix (`eslint . --fix`,
    repo-wide `prettier --write`); path-scoped only.

    ## Reading Files

    Read each file once, in full, with the Read tool - not `cat`, `sed`, or
    `head` through Bash. Revisit part of a file with `offset`/`limit` or a
    grep for the symbol; never re-read a file still in your context. Before
    a broad grep, check whether the answer is already in context.

    ## Code

    - Follow the brief's file structure; one clear responsibility per file.
      If a file or the work grows beyond the brief's intent, stop and
      report DONE_WITH_CONCERNS rather than restructure on your own. If an
      existing file you modify is already large or tangled, work carefully
      and note it as a concern.
    - Follow existing patterns. Improve code you touch; leave the rest.
    - Docstrings match a neighbouring module's shape: a one-line summary,
      at most one short paragraph on a non-obvious why. Comments are 1-2
      lines, state a reason, and never restate the code. Formulas and
      derivations belong in code, not prose docstrings.
    - Statistical tests: never search for a seed that passes. Derive the
      tolerance from the sampling distribution (e.g. 4 standard errors)
      and note the false-alarm rate. If no tolerance makes the test
      meaningful, report DONE_WITH_CONCERNS.

    ## Code Stands Alone

    The spec and plan are scaffolding, not part of the codebase. No file
    you create or modify, and no commit message, may point at them: no
    `docs/specs/` or `docs/plans/` paths, task or step numbers, section
    names, "per the spec", or "as designed". State the rule itself and,
    where non-obvious, its reason in domain terms ("retry 5x: upstream
    rate-limits bursts"). If the brief gives a value without a reason,
    leave the comment out. A value may cite the stable public source it
    comes from: a published paper, a standard or RFC, a named public data
    series, official vendor docs.

    If the brief lists changes to `ARCHITECTURE.md` or `docs/architecture/`,
    make them here. Those files describe the system as it now is, with no
    dates or history.

    ## Escalate

    Bad work is worse than no work. Report BLOCKED or NEEDS_CONTEXT when
    the task needs an architectural decision the brief does not make or a
    restructuring it did not anticipate, when focused reading does not
    give you clarity, or when you doubt your approach. Say what you are stuck on, what you tried, and what you need.

    ## Self-Review

    - Everything in the brief implemented, nothing extra?
    - Edge cases covered by tests that verify behavior, not mocks? Test
      output pristine?
    - Names say what things do?
    - No mention of the spec, plan, or task numbers in anything you wrote?
      Living-doc changes made?

    ## Report

    [REPORT_RULE]

    - **Status:** DONE; DONE_WITH_CONCERNS if complete but you doubt its
      correctness; BLOCKED if you cannot complete it; NEEDS_CONTEXT if you
      need information you were not given. Never silently hand over work
      you are unsure about.
    - What you implemented (or attempted, if blocked)
    - Commits (short SHA + subject) and files changed
    - **TDD evidence:** RED command + one-line result
      (`FAILED test_x: ImportError`), GREEN command + one-line result
      (`12 passed`)
    - One-line test summary: [TEST_SUMMARY_FIELDS]
    - Self-review findings and concerns, if any

    Test results are counts and one-line failure reasons, never pasted
    runner output. If BLOCKED or NEEDS_CONTEXT, put the specifics in your
    final message.
```

## Path-Specific Values

| Placeholder | subagent-driven-development | executing-specs |
|---|---|---|
| `[WHAT]` | Task N: [name] | the approved spec at [SPEC_PATH] |
| `[BRIEF_FILE]` | the task brief from `scripts/task-brief` | the spec file |
| `[BRIEF_NOTE]` | It holds the task's full text from the plan. | Its Implementation notes section is your file list, interfaces, and test intent. |
| `[BASELINE_AND_SEAM]` | omit | the Baseline and Test Seam sections below |
| `[COMMIT_NOTE]` | Conventional Commits subject; these commits are kept. | These are checkpoints the controller squashes later; wording does not matter. |
| `[FULL_RUN_RULE]` | You get one full-suite run and one whole-repo lint and type-check pass, immediately before your final commit; state the count in your report. | Never run the full suite or whole-repo lint or type-check; the controller's Verify step owns those. |
| `[REPORT_RULE]` | Write the report below to [REPORT_FILE]; fix rounds append to it. Then reply with only status, commits, the test summary, concerns, and the file path, under 15 lines. | Reply with the report below as your final message, under 15 lines. There is no report file. |
| `[TEST_SUMMARY_FIELDS]` | counts, and full-suite runs with a reason for each beyond the first | counts, the scoped command run, and any wider run with its reason |

`[TRAILER]` is the exact Co-Authored-By line from the controller's own
session attribution.

Baseline and Test Seam sections for executing-specs:

```
    ## Baseline

    At the base commit, verification results were:
    [per-command pass/fail from Setup's baseline, with a one-line summary
    of each pre-existing failure]

    A failure listed here predates your work: note it in your report and
    move on.

    ## Test Seam

    - Existing test to copy: [a test that already exercises the target
      path - clone its fixture setup - or "none - first test for this
      path"]
    - Scoped test command: [the exact command for this dispatch's tests]
```
