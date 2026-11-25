# Layer Boundaries

The enforceable rules behind `architecture/ARCHITECTURE.md`. Each is phrased so a grep/JSON
check can decide it; `scripts/check-architecture.sh` (contract in `scripts/SCRIPTS.md`,
implemented in **F004**) asserts them and a violation blocks "done". Until that script lands,
the inline self-check in `HARNESS-BOOTSTRAP.md` (baseline run recorded in `ADOPTION.md`) covers
them.

> Real rules, written at adoption from the structure the code already follows (archetype D).
> check-architecture is therefore an **enforcing gate** here, not a no-op.

## Allowed dependency direction
```
HARNESS-BOOTSTRAP.md (artifact)  ->  format + invariants (pure core)  ->  (nothing)
extraction / scaffold (I/O edge) ->  may read the artifact + write the tree
                                     the core may NOT import the edge
```
The pure core — the FILE-block grammar, the delimiter contract, the file inventory, the FILL
discipline, the agnostic wiring — depends on nothing (no tool, no filesystem, no network).
Everything else depends on it.

## The rules (each checkable)
1. **Delimiter integrity.** In `HARNESS-BOOTSTRAP.md`, `count('^FILE:') == count('^<<<BEGIN') ==
   count('^END>>>')`. No generated file under `.harness/` or any root pointer contains a
   **standalone** `<<<BEGIN` / `END>>>` line — grep `'^<<<BEGIN$'` / `'^END>>>$'` (no
   transcription leak). A backticked mention of the token in prose — e.g. this very file
   documenting the format — is not a leak.
2. **File inventory.** Scaffolding yields exactly 42 files under `.harness/` + 6 root
   entry-point pointers = 48.
3. **FILL discipline.** No file contains an unfilled `<<FILL`-colon placeholder (the blank the
   bootstrap leaves for the requirement files, the three first-run tracking files, and the
   `SESSION-CHECKLIST.md` Commands / `AGENTS.md` Tech-stack holes) outside that set. In this
   adopted repo they are all filled, so a scan for the colon-form marker returns nothing. A
   backticked mention of the token in prose — like this rule — is documentation, not a marker.
4. **Canonical contract is vendor-neutral.** `.harness/AGENTS.md` names no single vendor's tool
   as *the* tool; vendor names appear only in the root pointer files and the agnostic
   explanation. No rule inside the contract is tool-exclusive.
5. **Pointers don't fork the contract.** Every root entry-point file references
   `.harness/AGENTS.md` and contains no rule the contract doesn't — they are redirects, not
   copies.
6. **JSON twin valid.** `graph/graph.json` parses as JSON and its node / edge ids match
   `graph/workflow-graph.md`.
7. **Idempotent + non-clobbering.** Re-running the bootstrap never overwrites an existing file
   (it skips and reports); re-extraction is safe.
8. **No new runtime dependency.** The artifact stays runnable with only git + a POSIX shell +
   python3 (stdlib). Adding a dependency is a violation unless justified in the sprint contract.

## Rationale
The one boundary that matters most: **the format + invariants are the single source of truth,
and they are tool-free.** Every leak of a vendor assumption into the contract, or of content
into a machinery file, forks that truth and breaks portability.

## How to check
`scripts/check-architecture.sh` (F004) implements rules 1–8 as grep/json assertions and exits
non-zero on any violation; it runs in `init` and before any feature is marked passed. Until it
lands, run the inline self-check block from `HARNESS-BOOTSTRAP.md`.
