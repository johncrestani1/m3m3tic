# ADR-002: JSON Schema Draft 2020-12 for structural validation

## Status
Accepted

## Context
We need a schema language for validating the structure of .m3m3tic files.

Options considered:
- **JSON Schema Draft 2020-12**: Current standard, widest tooling support
- **JSON Schema Draft 07**: Older but more widely implemented
- **CUE**: Powerful constraints, but Go-only tooling
- **XML Schema (XSD)**: Not applicable to YAML
- **Metaschema (OSCAL)**: Generates JSON/XML/YAML schemas, but heavyweight

## Decision
Use JSON Schema Draft 2020-12.

## Rationale
- Industry standard for YAML/JSON validation
- Supported by ajv (JS), jsonschema (Python), serde (Rust)
- OPA/Conftest can validate against JSON Schema
- DTCG Design Tokens uses JSON Schema — aligns with our token format
- OpenAPI, OSCAL, and Sketch all use JSON Schema for their specs

## Consequences
- Schema file is JSON, not YAML (convention for JSON Schema files)
- Some older validators only support Draft 07 — we document the minimum required draft
- Complex cross-field validation (e.g., "if industry is MLM, then income_claims is required") is handled by OPA policies, not the schema
