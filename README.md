# minipowers

A minimal fork of [obra/superpowers](https://github.com/obra/superpowers) for
Claude Code. Six skills survived the cut. The hooks, the ports to other
harnesses, and most of the process scaffolding did not survive.

Forked from upstream **v6.1.1** (commit
[`d884ae0`](https://github.com/obra/superpowers/commit/d884ae04edebef577e82ff7c4e143debd0bbec99),
July 2026). Upstream history is preserved in this repo up to that commit.

Why each skill survived (and eight didn't): see [ANALYSIS.md](ANALYSIS.md).

## Skills

| Skill | What it does |
|---|---|
| **brainstorming** | Capture the idea as a committed `intent.md` in the user's words, then turn it into an approved, committed `spec.md` through one-question-at-a-time dialogue, with the repo's policy skills applied and concerns flagged. Hands off to writing-plans. |
| **writing-plans** | Turn a spec into bite-sized tasks with exact file paths, interfaces, and test intent, read-only until the plan is written. Sets the tier from the task count, takes one approval, commits `plan.md`. |
| **subagent-driven-development** | Execute a committed plan with fresh implementer subagents (one per task, or one for a small plan), adversarial review, and a fix loop in which a fresh reviewer judges every fix round. Deviations are appended to the plan; the change ends as a draft pull request. |
| **test-driven-development** | Red-green-refactor, with the step that matters spelled out: watch the test fail, for the right reason. Includes a debugging stop rule (three failed fixes means the problem is architectural). |
| **verification-before-completion** | No success claims without running the verification command in the same message. |
| **writing-skills** | TDD for process documentation: pressure-test a skill on subagents before trusting it. |

The flow follows Anthropic's
[AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook)
(published 2026-08-21, read 2026-10-24): each stage ends by committing an artifact the next stage reads, and the
chain of commits is the audit trail.

```
docs/changes/<YYYY-MM-DD-topic>/
  intent.md    the idea in the user's words      brainstorming, committed on confirm
  spec.md      requirements and design           brainstorming, committed on approval
  plan.md      tasks, risks, proof, amendments   writing-plans, committed on approval
the diff                                         subagent-driven-development
the PR         findings, verification, decisions subagent-driven-development
```

`docs/changes/` is the playbook's `intent/` home under a clearer name. The
flow is **brainstorming → writing-plans → subagent-driven-development** at
every size. Writing-plans sets the tier from the plan it just wrote:

- **Light** (at most 3 tasks, about 10 files): one implementer for the
  whole plan, no per-task gates, one whole-branch review, one squashed
  commit.
- **Heavy** (anything larger): one implementer and one review per task, a
  commit per task, then the whole-branch review.

Both tiers use TDD inside implementation and verification before every
completion claim. The review loop borrows from
[no-mistakes](https://github.com/kunchenguid/no-mistakes) v1.100.1: a fresh reviewer
every round, fix-round code reviewed as unreviewed new code, findings that
enumerate every sibling site, a coverage record, and ask-user findings for
remedies that would extend the change.

Intent, spec, and plan are the change's record: the plan is amended as the
change is built and all three freeze at merge. Nothing in the codebase may
cite them. `ARCHITECTURE.md` at the repo root is the living description of
the current system, updated by every change that alters it. Subagent model
policy is fixed: implementers run on Sonnet, task reviewers on Opus, and
the final reviewer on the strongest available model (Fable, else Opus).

The in-session final review is the layer before the PR, not the merge
gate. The controller pushes and opens a draft PR; marking it ready is the
human's, and approval is a code owner's through branch protection. If the
repo has a `REVIEW.md` at its root, the final reviewer runs its passes and
respects its nit cap and do-not-report list.

### Optional hook: protect tests during fix rounds

Fixers are told never to edit an existing test to make it pass. To make
that deterministic, the controller creates `.minipowers/sdd/fix-round`
before each fixer dispatch and removes it afterwards. A consuming repo can
deny test edits while the marker exists, for example in
`.claude/settings.json` (needs `jq`; adjust the test-path pattern):

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write|MultiEdit|NotebookEdit",
      "hooks": [{
        "type": "command",
        "command": "f=$(jq -r .tool_input.file_path); if [ -e .minipowers/sdd/fix-round ] && echo \"$f\" | grep -qE '(^|/)(tests?|__tests__)/|_test\\.|\\.test\\.'; then echo 'fix round: test files are read-only' >&2; exit 2; fi"
      }]
    }]
  }
}
```

## Install

From a local clone:

```
/plugin marketplace add /path/to/minipowers
/plugin install minipowers@minipowers-dev
```

Or straight from GitHub:

```
/plugin marketplace add ipoeyke/minipowers
/plugin install minipowers@minipowers-dev
```

There is no SessionStart hook. Skills trigger through Claude Code's normal
description-based routing, or explicitly (`/minipowers:brainstorming`, etc.).

## What was cut from upstream

Eight skills, the SessionStart hook, and all the packaging for other
harnesses. Three of the eight (requesting-code-review, receiving-code-review,
systematic-debugging) were folded into the surviving skills rather than
deleted outright. The full list and per-skill rationale are in
[ANALYSIS.md](ANALYSIS.md).

## Credit

The good ideas here are Jesse Vincent's
([obra/superpowers](https://github.com/obra/superpowers), MIT). This fork
only takes things away.

The artifact chain (intent, spec, plan, diff, PR), plan approval, live plan
amendments, the REVIEW.md pass structure, and the no-merge rule follow
Anthropic's [AI-native SDLC playbook](https://claude.com/resources/articles/the-ai-native-sdlc-playbook),
published 2026-08-21 and read 2026-10-24 (the article carries no version
number). The review
loop's fresh-reviewer, class-once, coverage-record, and ask-user rules are
adapted from [kunchenguid/no-mistakes](https://github.com/kunchenguid/no-mistakes)
v1.100.1 (commit
[`c80c10f`](https://github.com/kunchenguid/no-mistakes/commit/c80c10f254ebf9a12524ad26b8eeb2f8714e97c4),
MIT).

Three questioning habits in the brainstorming skill (look up facts instead of
asking, attach a recommended answer to every question, resolve decisions in
dependency order) were adapted from Matt Pocock's
[grilling skill](https://github.com/mattpocock/skills/blob/5beb35b040e3de97e54fa9e386d7e42d15c295c2/skills/productivity/grilling/SKILL.md)
(commit `5beb35b`, MIT).
