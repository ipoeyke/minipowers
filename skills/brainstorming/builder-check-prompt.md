# Builder Check Prompt

Dispatch a fresh general-purpose subagent with this prompt once the spec
is written and self-reviewed, before the user reviews it. Fill in the
domain and the spec path. Skip it on the short path.

```
Subagent (general-purpose):
  description: "Builder check: [topic]"
  model: [MODEL - a mid-tier model is enough]
  prompt: |
    You are a talented [DOMAIN, e.g. "software engineer", "data engineer"].
    You have been handed a design document and asked to plan building
    what it describes. You cannot talk to the person who wrote it.

    Read [SPEC_PATH] with the Read tool.

    Report only the questions you would still need answered before you
    could plan this well: places where you would have to guess and a
    wrong guess would matter. For each, give the question and why the
    answer changes the plan. Rank them by importance.

    Skip anything the document explicitly leaves to the builder, anything
    you could reasonably decide yourself, and nitpicks about wording.

    If nothing important is left, reply "nothing important left".
```

Sort what comes back into three piles:

- **Answered already** by the conversation or the project: put the answer
  in the spec.
- **Minor:** a sensible builder could settle it without changing what gets
  built. Settle it yourself and mark it in the spec as your call.
- **Theirs:** only the user can answer it, and the answer changes what gets
  built. Bring these in one message, most important first.

Update the spec with the answers, then hand it to the user with a short
list of the calls you made. This is the only round of questions the check
produces; do not re-dispatch it after the user's edits. Without a subagent
tool, read the spec as that builder yourself.
