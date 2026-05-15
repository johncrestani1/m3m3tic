# Implementations

Tools and services that support the `.m3m3tic` file format.

## Authoring Tools

| Tool | Status | Notes |
|---|---|---|
| [Bonfire Terminal](https://bonfire.dev) | In Development | Reference implementation. Creates, validates, and signs `.m3m3tic` files. |

## Validators

| Tool | Status | Notes |
|---|---|---|
| JSON Schema (ajv) | Available | Basic structural validation via `schemas/v0.1.0/m3m3tic.schema.json` |
| Conftest + OPA | Available | Compliance rule validation via `policies/` directory |

## Parsers / Readers

_No third-party parsers yet. The format is standard YAML — any YAML parser can read it._

## Want to add your tool?

Open a PR adding your implementation to the appropriate table above.
