# ADR-003: OPA/Rego for compliance validation

## Status
Accepted

## Context
JSON Schema validates structure (types, required fields, enums) but cannot validate business logic like "if the industry is MLM, an income disclaimer must exist" or "good_examples must not contain prohibited terms."

Options considered:
- **OPA/Rego**: Purpose-built policy language, used by Kubernetes, Terraform, and cloud-native tooling
- **Cedar (AWS)**: Newer, simpler syntax, but smaller ecosystem
- **Custom code**: Maximum flexibility, but not portable across tools
- **CUE constraints**: Powerful, but Go-only

## Decision
Use OPA/Rego policies validated via Conftest.

## Rationale
- Conftest (`conftest test file.m3m3tic --policy policies/`) is the simplest CLI experience
- Rego policies are portable — same policies work in Conftest (CLI), OPA server (API), and Go embedded (Bonfire Terminal)
- Two-layer enforcement: Go/OPA for user-side instant feedback in Bonfire, Starlark/Bazel for CI-side deterministic proof
- Policy packs can be distributed independently (industry-specific, jurisdiction-specific)
- OPA is CNCF graduated — long-term viability is assured

## Consequences
- Users need Conftest installed for CLI validation (or use Bonfire Terminal which embeds OPA)
- Rego has a learning curve for custom policies
- Policy packs become a monetization vector (free: basic FTC; paid: FDA, SEC, GDPR, jurisdiction-specific)
