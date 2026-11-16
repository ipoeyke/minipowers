---
name: writing-skills
description: Use when creating or editing a skill, a subagent prompt template, or any other text in this repository that instructs an agent
---

# Writing Skills

A skill is tested the way code is: watch an agent fail without the change,
make the change, watch a fresh agent succeed. Text that was never run
against an agent is a guess about what agents do.

## The Cycle

1. **Baseline.** Build a scenario that tempts the failure and run it on a
   fresh subagent with the current text, or with no skill for a new one.
   Give it real files and a real task, not a question about the skill.
   Record what it did and, where it explains itself, its own words. If the
   baseline does not show the failure, stop: there is nothing to fix.
2. **Write the smallest change that answers what you saw.** Nothing for
   cases no run produced.
3. **Re-test** the same scenario on fresh subagents with the new text.
   Read every output yourself: counts alone overstate both failure and
   success.
4. **Repeat** when a run finds a new way around the text.

Run subagents on the model that reads the text in use. Where a result
decides a design question, run several per variant: one sample misleads,
and five runs with five different shapes mean the wording is not binding.
State in the PR how many runs each variant got.

A rule the agent knows and is tempted to skip is tested under combined
pressure: a deadline, sunk cost, someone with authority asking for the
shortcut. The scenario makes the agent act, never describe what it would
do.

## Match the Form to the Failure

Classify the baseline failure before writing. The form that fixes one
kind makes another worse.

| Baseline failure | Form that works | Form that fails |
|---|---|---|
| Skips a rule it knows, under pressure | The rule once, with its reason, and a counter to the shortcut the baseline showed | Soft guidance ("prefer", "consider"); shouted absolutes |
| Complies, but the output has the wrong shape | A recipe: what the output is, its parts in order | A list of things not to do |
| Leaves out a required element | A named slot in the template it fills | A reminder in prose near the template |
| Should behave differently by case | A conditional on something observable ("if the brief exists") | A blanket rule with exemption clauses |

"Don't X unless it matters" reopens the negotiation the rule closed, and
an exemption clause does not stop a rule reaching the exempted part.
Write a real exception as its own conditional, or restructure so the rule
cannot reach it.

## Wording

- State a rule once, at normal volume, with its reason. Capitals, "no
  exceptions", and tables of forbidden excuses make current models apply
  a rule past its scope and let it outweigh the user's own instructions.
- The description says when to use the skill and nothing about what it
  does. An agent that reads a workflow summary there follows the summary
  and skips the body.
- Every line is read on every use. Text the model would produce unasked
  earns no space; cut before adding.
- One example, chosen for the hard case.
- A second file only for a template, a script, or a reference too long to
  read on every use.
