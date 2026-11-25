---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/*_test.*"
  - "**/test_*.py"
  - "**/tests/**"
  - "**/e2e/**"
---

# Writing tests

- Cover the `.harness/verification/edge-cases.md` categories that sprint contract §2 names, each
  with a test that asserts real behavior.
- A user-facing flow gets an e2e test against the real stack
  (`.harness/verification/acceptance-evidence.md`): deterministic, seeded, no sleep-and-hope.
- No `assert true`, no skipped test, no test edited to pass. Flaky is broken — fix the cause.
- Match the existing tests' style, helpers and layout before adding new ones.
