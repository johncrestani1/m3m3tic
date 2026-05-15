# ADR-001: YAML as the file format

## Status
Accepted

## Context
We need a file format for .m3m3tic that is human-readable, machine-parseable, and supported by existing validation tooling.

Options considered:
- **JSON**: Machine-friendly, but poor human readability for multi-line strings (voice descriptions, disclaimers)
- **YAML**: Human-readable, supports multi-line strings natively, comments for documentation
- **TOML**: Good for flat config, poor for deeply nested structures
- **CUE**: Self-validating, but no Rust embedding and not yet 1.0

## Decision
Use YAML 1.2 as the file format.

## Rationale
- Brand managers and marketers need to read and occasionally hand-edit the file
- YAML supports multi-line strings (`>` and `|`) essential for disclaimers and voice descriptions
- JSON Schema validates YAML (via conversion) — mature tooling exists
- OPA/Conftest natively supports YAML input
- Every major language has a YAML parser
- Comments allow inline documentation without polluting the data

## Consequences
- Must handle YAML's known footguns (Norway problem, boolean coercion) via strict schema
- Version field must be quoted string (`"0.1.0"` not `0.1.0`) to prevent float interpretation
- Price range `$` must not be interpreted as a YAML anchor
