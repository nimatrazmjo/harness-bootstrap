# DATA MODEL

**N/A — no persistent domain model.** Archetype D (docs/tooling). The only structured "data" is
the FILE-block grammar of `HARNESS-BOOTSTRAP.md` and its JSON twin `graph/graph.json`; both are
described in `architecture/ARCHITECTURE.md` (the pure core) and enforced by
`rules/layer-boundaries.md`, not stored anywhere at runtime.

If a future feature adds persistent state (e.g. a manifest of generated files), define its
entities + invariants here then.
