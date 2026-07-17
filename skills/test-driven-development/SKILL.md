---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development (TDD)

## Overview

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it
tests the right thing. Tests written after code pass immediately — and passing
immediately proves nothing: they test what you built, not what was required.

**The rule:** no production code without a failing test first. Wrote code
before the test? Delete it and start from the test. Exceptions (throwaway
prototypes, generated code, config) need your human partner's sign-off.

## Red-Green-Refactor

**RED — write one minimal failing test.** One behavior, clear name, real code
(mocks only when unavoidable). If the name needs "and", split it.

**Verify RED — run it and watch it fail. Mandatory.** Confirm it FAILS (not
errors), and fails for the RIGHT reason — the feature is missing, not a typo
or import error. This step is where wrong test expectations get caught: a
fixture that can't fail, an assertion that's mathematically unsatisfiable, a
test that passes against current behavior. If the test passes immediately,
it tests existing behavior — fix the test.

**GREEN — write the simplest code that passes.** No extra features, no
speculative options, no "while I'm here" improvements. YAGNI.

**Verify GREEN — run it and watch it pass.** Other tests still green, output
pristine (no new warnings). Test fails? Fix the code, not the test.

**REFACTOR — after green only.** Remove duplication, improve names, extract
helpers. Stay green. Then repeat with the next failing test.

## Good Tests

| Quality | Good | Bad |
|---------|------|-----|
| **Minimal** | One thing per test | `test('validates email and domain and whitespace')` |
| **Clear** | Name describes behavior | `test('test1')` |
| **Shows intent** | Demonstrates desired API | Tests the mock, not the code |

## Bug Fixes

A bug fix is a feature whose test is the reproduction. Write a failing test
that reproduces the bug, verify it fails on current code, then fix. Never fix
a bug without a test — the test proves the fix and prevents regression.

**Before hypothesizing a fix, find the root cause:**
- Read the full error and stack trace; check what changed recently.
- In multi-component systems, instrument the component boundaries (log what
  enters and exits each layer) and run ONCE to see WHERE it breaks, before
  theorizing about WHY.
- **Stop rule: three failed fix attempts means the problem is architectural,
  not local.** Each fix revealing a new symptom elsewhere is the signature.
  Stop patching, question the design with your human partner.

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the wished-for API; write the assertion first |
| Test too complicated | Design too complicated — simplify the interface |
| Must mock everything | Code too coupled — inject dependencies |
| Test setup huge | Extract helpers; still complex? simplify the design |

## Anti-Patterns

When adding mocks or test utilities, read
[testing-anti-patterns.md](testing-anti-patterns.md): testing mock behavior
instead of real behavior, test-only methods on production classes, mocking
without understanding the dependency.

## Final Rule

```
Production code → a test exists and you watched it fail first
Otherwise → not TDD
```
