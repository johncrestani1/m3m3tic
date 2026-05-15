# .m3m3tic File Format Specification

**The portable, machine-readable standard for brand identity + legal compliance.**

> A `.m3m3tic` file is a single YAML document that describes everything a tool needs to create on-brand, legally compliant marketing content: visual identity, voice guidelines, platform-specific rules, regulatory constraints, and provenance metadata.

## Status

| Component | Version | Status |
|---|---|---|
| Specification | 0.1.0 | Draft |
| JSON Schema | 0.1.0 | Draft |
| Reference Examples | 3 | Available |
| OPA Policy Packs | 3 | Draft |

## Quick Start

1. Copy `examples/minimal.m3m3tic` as a starting point
2. Validate with the JSON Schema: `ajv validate -s schemas/v0.1.0/m3m3tic.schema.json -d your-brand.m3m3tic`
3. Run compliance checks: `conftest test your-brand.m3m3tic --policy policies/`

## Repository Structure

```
spec/                  # The formal specification document
schemas/               # JSON Schema for validation (Draft 2020-12)
examples/              # Reference .m3m3tic files
policies/              # OPA/Rego compliance rule packs
tests/
  valid/               # Files that MUST pass validation
  invalid/             # Files that MUST fail validation
decisions/             # Architecture Decision Records
```

## What Problem Does This Solve?

Today, brand identity lives in PDFs that no tool can read. Legal compliance lives in lawyers' heads. Platform rules live in each platform's documentation. When a marketing team creates an ad, they manually cross-reference all three — and get it wrong constantly.

A `.m3m3tic` file makes all three machine-readable, validatable, and enforceable:

- **Brand identity** — Visual tokens, voice guidelines, terminology rules
- **Legal compliance** — FTC, FDA, GDPR, jurisdiction-specific disclaimers
- **Platform rules** — Meta Ads API fields, creative specs, prohibited patterns

## Licensing

- **Specification & Schema**: Apache 2.0 (this repository)
- **Bonfire Terminal Validator**: BSL 1.1 (separate repository)
- **Read-only Parser SDK**: Apache 2.0 (separate repository, coming soon)

See [LICENSE](LICENSE) for details.

## Governance

This specification is maintained by [Bonfire Terminal](https://bonfire.dev). See [GOVERNANCE.md](GOVERNANCE.md) for the decision-making process.

## Implementations

See [IMPLEMENTATIONS.md](IMPLEMENTATIONS.md) for tools that support the `.m3m3tic` format.
