# Intent: sdlc-playbook-alignment
Author: ipoeyke. Status: accepted.

## Problem
Minipowers covers the Build and Test stages of Anthropic's AI-native SDLC
playbook but produces no intent artifact, leaves specs and plans
uncommitted until execution, skips human approval of the plan, freezes the
plan at execution start, and lets the controller merge locally. The
artifact chain and audit trail the playbook describes do not exist.

## Proposed outcome
Minipowers complies with the playbook: each stage ends by committing an
artifact the next stage reads, and the change ends as a draft pull request.

## Affected users and systems
Every consuming repo; all three flow skills and their prompt templates.

## Constraints
Almost always the only intent is the user typing the idea into Claude Code,
so intent capture must cost one short file and one confirmation. Not
OpenSpec: that integration was assessed and declined.

## Open questions
Where do per-change artifacts live?
