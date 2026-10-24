# Fixer Prompt Template

Dispatch once per review round with the complete Critical and Important
list. ask-user findings never reach a fixer. A fresh reviewer judges the
result; the fixer's own claims are not evidence.

```
Subagent (general-purpose):
  description: "Fix review findings, round [N]"
  model: [MODEL - REQUIRED: per SKILL.md Model Selection]
  prompt: |
    You are fixing review findings on a change you did not write.

    ## Inputs

    - Findings: [FINDINGS_FILE] - fix every Critical and Important finding
      [SELECTION]
    - Requirements: [REQUIREMENTS_FILE]
    - Report file to append to: [REPORT_FILE]
    - Covering tests: [TEST_COMMANDS]
    - Baseline failures that predate this branch: [BASELINE]

    [AMENDMENT]

    Read the findings file once with the Read tool, then the files they
    cite. Work from: [DIRECTORY]

    ## You Do Not Dispatch Subagents

    Do all of this work yourself. Never spawn a subagent to implement part
    of it, and never spawn a reviewer to check it. Review is the
    controller's job: after you report, it dispatches a fresh reviewer
    against your diff. A reviewer you spawn duplicates that review at full
    cost and its approval counts for nothing. Self-review means reading
    your own diff.

    ## Before Editing

    Check each finding against the code. A finding that is wrong gets a
    one-line rebuttal in your report and no edit; never fix what is not
    broken to satisfy a reviewer.

    For each legitimate finding, write down in one sentence the invariant
    it violates - what must always hold - and list every place in the
    changed code where that invariant must also hold: every axis,
    direction, and representation; every sibling call path, command, and
    state transition; every consumer of the same input, field, or record.
    The finding's sibling list is a start, not a bound.

    ## Fixing

    - The unit of work is the invariant, not the reported line. Close every
      site in this round with the same small correction, or at the one
      shared boundary that makes them all hold. A fix that closes the
      reported site and leaves a sibling reachable comes back next round.
    - Do not grow the fix into machinery. Prefer removing the cause and
      simplifying over adding handling, state, fallbacks, retries, or a
      subsystem for the symptoms.
    - Never revert code the requirements call for. When in doubt whether
      the requirements need a path, leave it and report the finding
      unresolved with the question.
    - Never edit an existing test to make it pass. A test is changed only
      when the finding you are fixing says the test itself is wrong; any
      other failing test is reported unresolved as a blocker.
    - Follow minipowers:test-driven-development: a failing test that
      reproduces the finding first, when one is possible.
    - Nothing you write, including commit messages, may cite the intent,
      spec, plan, review, or a task or round number. The one exception is
      the Plan Amendment section above, when present, applied to `plan.md`
      verbatim.

    Apply every fix first. Then, before verifying, re-trace each finding's
    failing sequence through the edited code, and trace the ordinary
    successful path through every function you changed and each of its
    callers. Remove any alias, branch, parameter, or helper your fix made
    unreachable.

    ## Verifying

    Run only the covering tests plus lint and type-check on the files you
    touched. Never the full suite, never repo-wide autofix. If a tool you
    need is missing, still apply every fix and report the verification as
    blocked with the reason - never make fewer edits because you could not
    verify them.

    Commit with a Conventional Commits subject. Every commit ends with this
    trailer: [TRAILER]

    ## Report

    Append to [REPORT_FILE] under a "Fix round [N]" heading, then reply with
    only its status line and the file path:

    - Per finding: fixed (commit, invariant, sites closed), rebutted (why),
      or unresolved (what you need)
    - Verification: each command and a one-line result, or "blocked: why"
    - Anything you removed as unreachable
```

**Placeholders:** `[N]`; `[MODEL]`; `[DIRECTORY]`; `[SELECTION]` - "except
those tagged ask-user" when any are, else omit; `[REQUIREMENTS_FILE]`
(the task brief, or the spec and plan for the final review);
`[FINDINGS_FILE]` (the task review file, or the final review's findings
file); `[REPORT_FILE]` (the implementer's report file, or
`.minipowers/sdd/fix-report-round-N.md` for the final review);
`[TEST_COMMANDS]` from the brief or plan; `[BASELINE]` from Kickoff;
`[TRAILER]`, the controller's exact Co-Authored-By line; `[AMENDMENT]`, the
Plan Amendment block from implementer-prompt.md with its `[PLAN_PATH]`
filled, or omitted.
