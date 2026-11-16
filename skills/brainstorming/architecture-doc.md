# Writing ARCHITECTURE.md

`ARCHITECTURE.md` is a map of the whole repository for a contributor who
has never worked in it. Finding where a change belongs costs a newcomer
far more than writing it, and the map closes that gap. For any part of the
repository it answers two questions: "where is the code that does X?" and
"what does the code I am looking at do?".

## Starting a New File

Write it from the repository as it stands, before designing the change
that prompted it. The change is not a subject of the document: the area
it touches is one codemap entry like any other.

Survey in this order:

1. The README, the build and package manifests, and the tracked tree two
   levels deep (`git ls-files | cut -d/ -f1-2 | sort -u`).
2. Entry points: binaries and `main` functions, CLI commands, server
   start-up, exported package API, hooks, scheduled jobs.
3. One typical request, command, or build, traced from an entry point to
   its output. This is the runtime flow.
4. Which top-level units depend on which, and which directions never
   occur. The absences are the invariants.

Then write the sections below. Before committing, check coverage against
the tree from step 1:

- every top-level directory and package appears in the codemap or in its
  out-of-scope line;
- the entry for the area this change touches is no longer than the
  entries around it.

## Sections

In this order. Leave one out only when the repository has nothing to put
in it.

1. **Overview.** What the system is for, what goes in and what comes out,
   and what it is commonly mistaken for but is not. One or two paragraphs.
2. **How it runs.** The main flow as numbered steps or one diagram: the
   pipeline stages, the path of a request, the start-up sequence, or the
   process model, whichever the system has.
3. **Entry points.** Where execution starts and which file to read first.
4. **Codemap.** One entry per top-level unit (directory, package, crate,
   service), ordered by layer or by the flow above, not alphabetically.
   Each entry says what the unit is for, names the few files or types
   that matter most in it, and states what it must not know or do. The
   last line names what is out of scope: generated, vendored, fixtures.
5. **Cross-cutting concerns.** What no single unit owns: error handling,
   testing, configuration, logging and metrics, concurrency and
   cancellation, compatibility guarantees, code generation. One short
   paragraph each, only for those the repository has a rule about.
6. **Key decisions.** The choices that shape the whole system, each with
   its reason, including the dependencies it rests on and why those.

## Rules

- **Stable facts only.** Write what is unlikely to change from one month
  to the next: roles, boundaries, rules. How a unit works inside belongs
  in its own doc comments, or in `docs/architecture/<area>.md` once an
  area outgrows its codemap entry. This is a map of the country, not an
  atlas of its states.
- **Short.** Every line is one more line a later change can make false.
  When the file grows past what a newcomer reads in one sitting, move an
  area out to `docs/architecture/<area>.md`.
- **Name, do not link.** Name the important files, modules, and types in
  backticks so a symbol search finds them. Links into code go stale; a
  name needs no maintenance. Links to `docs/architecture/` files are fine.
- **Invariants are labelled.** Start each with `**Invariant:**` so one
  search finds them all, and put it inside the codemap entry or
  cross-cutting paragraph it constrains. Look hardest for those stated as
  an absence ("nothing in `model` imports `views`"): reading the code
  never reveals them. Confirm each with a search before writing it; one
  you cannot confirm is left out.
- **Boundaries are marked.** Say where one layer or system ends and the
  next begins, and what may cross: a public API, a wire format, a
  process boundary.
- **Diagrams show structure.** A layer stack, a pipeline, a process
  model, in Mermaid or ASCII. No diagram that restates a list.
- **Present tense, present system.** No dates, no history, no planned
  work, no reference to an intent, spec, or plan.

## Updating an Existing File

A change edits the entries it makes wrong and adds an entry for each unit
it introduces, at the depth of the entries around it. It adds no section
about itself.
