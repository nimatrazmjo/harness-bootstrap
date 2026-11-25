# API SURFACE

**N/A — no served API.** Archetype D (docs/tooling). The harness exposes no HTTP/RPC surface.

Its closest thing to a "contract" is the **consumption interface** of the distributable
(detailed in `architecture/ARCHITECTURE.md`):
- **Input**: `HARNESS-BOOTSTRAP.md` at a repo root + a coding agent (or the helper extractor).
- **Output**: the `.harness/` tree (42 files) + 6 root entry-point pointers.
- **Invariants that must hold on output**: the self-check in `HARNESS-BOOTSTRAP.md`, codified in
  `rules/layer-boundaries.md`.

If a CLI is ever added (e.g. `harness init`), document its commands / flags / exit codes here.
