---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

Run the command that proves a claim, in this message, before making the
claim. An earlier run, another agent's report, or a narrower check is not
evidence for it: the code changed since the earlier run, and a report
describes what its author meant to do.

1. Name the command that proves the claim.
2. Run it in full.
3. Read the output: exit code, failure count.
4. State the claim with that evidence. If the output does not support
   it, or you did not run the command, say what is known instead.

| Claim | Requires | Not sufficient |
|-------|----------|----------------|
| Tests pass | Output of the test command your task scopes you to: 0 failures | An earlier run, "should pass", a wider run than you were asked for |
| Linter clean | Linter output: 0 errors | A partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs that look fine |
| Bug fixed | The original symptom, re-tested: gone | Code changed, assumed fixed |
| Regression test works | It fails with the fix reverted and passes with it restored | It passes once |
| Agent completed | The diff shows the changes | The agent reports success |
| Requirements met | Each requirement checked against the result | Tests passing |

This covers every wording of success ("done", "fixed", "should pass now",
"looks good") and applies before each commit, push, PR, and move to the
next task.
