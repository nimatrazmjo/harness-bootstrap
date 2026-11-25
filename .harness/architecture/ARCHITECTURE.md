# ARCHITECTURE

Archetype **D — docs / tooling / single-artifact distribution** (`architecture/ARCHETYPES.md`).
The "product" is a specification distributed as one file, plus the `.harness/` tree it
generates. No server, no datastore, no long-running runtime.

## Layers (dependencies point inward to a pure core)
```
HARNESS-BOOTSTRAP.md  (the distributable: prose + 48 FILE: blocks)   -- the published artifact
        | defines
        v
format + invariants  (the pure "core": the FILE-block grammar, the   -- pure, framework-free,
delimiter contract, the file inventory, the FILL discipline, the         decidable by grep/json
agnostic wiring, the graph.json<->workflow-graph.md twin)
        | materialized by
        v
extraction + scaffold  (an agent writes the files; or the helper      -- thin I/O at the edge
extractor script)
        | produces
        v
.harness/ tree (42) + 6 root entry-point pointers                     -- generated output
```

## The pure core (what everything depends on and that depends on nothing)
The **meaning of a valid scaffold**, independent of any tool or filesystem:
- the FILE-block grammar: `FILE: <path>` -> `<<<BEGIN` … `END>>>`, delimiters balanced and never
  leaking into output;
- the file inventory: 42 under `.harness/` + 6 root pointers = 48;
- the FILL discipline: machinery carries no `<<FILL>>`; only the requirement files, the three
  first-run tracking files, and the Commands / Tech-stack holes do (greenfield);
- the agnostic wiring: one canonical contract (`.harness/AGENTS.md`), N thin pointers, no copy;
- `graph/graph.json` is a valid JSON twin of `graph/workflow-graph.md`.
These are enforced by `rules/layer-boundaries.md` (grep/json checks), not by any framework.

## Repository shape
```
HARNESS-BOOTSTRAP.md   # the distributable (the product) -- edit here, re-extract to refresh .harness/ machinery
README.md              # how to use it
.harness/              # the generated harness for THIS repo (dogfooded -- adopted)
AGENTS.md  CLAUDE.md  GEMINI.md  .github/copilot-instructions.md
  .cursor/rules/harness.mdc  .windsurf/rules/harness.md    # root entry-point pointers -> .harness/AGENTS.md
```

## Runtime topology
None. The artifact is consumed at author-time by a coding agent; the only "execution" is an
agent (or the extractor) writing the files, and the self-check reading them back.

## DATA_MODEL / API_SURFACE
N/A for this archetype — see those files for why and for the one "contract" that does exist (the
consumption interface of the distributable).
