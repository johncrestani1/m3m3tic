# Changelog

All notable changes to the .m3m3tic specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Spec status labels: **Draft** | **Candidate** | **Standard**

---

## [0.2.0] - 2026-05-17 [Draft]

### Architecture (BREAKING)
- **Two file types only**: `.m3m3tic` (brand + relationships + policy declarations) + `.cr3st4n1` (identity). Removed concept of `.m3m3tic-sow`.
- **Jurisdiction-neutral base schema**: No regulator's logic (FTC, ASA, GDPR, etc.) embedded in schema. All jurisdiction rules live in external OPA/Rego policy packs.
- **Evaluation function**: `ALLOW/DENY = f(actor, relationship, brand, content, medium, claims, platform, jurisdiction[])`. Never evaluate content, actor, or role in isolation.
- **Emergent composition**: "Most restrictive wins" emerges from running all applicable policies. No declared restriction algebra in schema.

### Added
- `relationships[]` section: actors who can operate on behalf of the brand (agency, affiliate, influencer, employee, reseller, franchisee, advocate)
- `claims` section: evidence substantiation requirements with approved sources
- `legal.jurisdictions[]`: declares operating jurisdictions + policy pack references
- `disclosures.platform_renderings`: per-platform disclosure rendering hints
- `protocol` section: on-chain settlement configuration (Base L2, USDC, EIP-712)
- `entity.structure`: direct selling model metadata (for MLM use case)
- `entity.registrations`: per-jurisdiction tax/registration IDs
- `entity.industry`: IAB taxonomy IDs for universal product classification
- 23 policy packs covering 15+ jurisdictions (US, EU, GB, RU, CN, AU, CA, JP, KR, BR, IN, AE, SA, NG, SG, TR, MX)
- Jurisdiction dependency graph (`_jurisdiction-graph.yaml`) with inheritance model
- MLM-specific income claims policy pack (12 jurisdictions)
- Brand-level policies: `terminology.rego`, `delegation-scope.rego`
- Shared policy interface: `_interface.rego` with common helper functions
- Taxonomy Rosetta Stone: 1:1:1:1:1 mapping (erid, Meta, Google, IAB, GB 45438, EU AI Act)
- `bonfire.m3m3tic` example: real affiliate template with 10% protocol fee
- `herbalife-distributor.m3m3tic` example: comprehensive MLM file with 26 jurisdictions

### Changed
- `brand` section restructured: `voice`, `terminology`, `visual`, `platform_config` (was `brand.visual`, `brand.voice`, `brand.terminology`, `platforms`)
- `platforms` moved under `brand.platform_config` (brand owns platform configuration)
- `legal` section completely restructured: now just jurisdiction declarations + policy pack references (was hardcoded FTC/FDA/income_claims sections)
- Examples updated to v0.2.0 format

### Removed
- Hardcoded `legal.ftc`, `legal.fda`, `legal.income_claims` sections (moved to policy packs)
- `enforcement.policy_packs` (replaced by `legal.jurisdictions[].policy_packs`)
- Old policy files: `ftc-endorsement.rego`, `fda-supplement.rego`, `income-claims.rego` (replaced by jurisdiction-structured packs)
- Concept of restriction algebra declarations (emerges from policy evaluation)
- `speech_authority` / `spend_authority` as separate sections (unified under `relationships[].authority`)

### Migration from v0.1.0
See `spec/v0.2.0/m3m3tic-spec-v0.2.0.md` Section 2 for the five-layer architecture.

Key changes for implementors:
1. Move `legal.ftc.*` logic into policy packs (don't embed in schema)
2. Move `brand.visual/voice/terminology` under `brand.` (same content, new paths)
3. Move `platforms.*` under `brand.platform_config.*`
4. Add `relationships[]` for each actor type
5. Add `legal.jurisdictions[]` declaring which policy packs apply

---

## [0.1.0] - 2026-05-15 [Superseded]

### Added
- Initial specification draft (v0.1.0)
- JSON Schema (Draft 2020-12) for structural validation
- 7 top-level sections: entity, brand, platforms, legal, reporting, provenance, enforcement
- 3 reference examples: minimal, Herbalife distributor, SaaS company
- 3 OPA/Rego policy packs: FTC endorsement, FDA supplement, income claims
- Conformance test suite (valid + invalid test cases)
- Architecture Decision Records (ADR-001 through ADR-003)
