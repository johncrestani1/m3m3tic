# .m3m3tic File Format Specification

**The portable, machine-readable standard for brand identity + legal compliance.**

> A `.m3m3tic` file is a single YAML document that describes everything a tool needs to create on-brand, legally compliant marketing content: visual identity, voice guidelines, platform-specific rules, regulatory constraints, and provenance metadata.

---

## Why This Exists

Today, marketing compliance lives in:
- **PDFs** that no tool can read (agency contracts, brand guidelines)
- **Lawyers' heads** (FTC rules, GDPR requirements, ASA guidance)
- **Platform documentation** (Meta Ads specs, Google Ads policies)
- **Scattered spreadsheets** (disclosure checklists, approval workflows)

When a marketing team creates an ad, they manually cross-reference all of these — and get it wrong constantly. The result: FTC enforcement actions, platform ad rejections, brand inconsistency, and $50M+ fines (Australia ACL).

A `.m3m3tic` file makes all of it machine-readable, validatable, and enforceable.

---

## What .m3m3tic Replaces

| Before (PDFs, emails, tribal knowledge) | After (.m3m3tic) |
|---|---|
| 12-page agency contract (Salvo Media x Ring Concierge) | `agency` + `sla` sections with Meta API operation mappings |
| Brand guidelines PDF (colors, fonts, voice) | `brand_authority` section with DTCG design tokens |
| FTC compliance checklist (manual review) | `legal.regulations.ftc` + OPA/Rego auto-validation |
| Platform ad specs (character limits, CTA options) | `platforms.meta.creative` with exact API field mappings |
| Influencer disclosure memo ("remember to add #ad") | `disclosures.renderings.instagram` with API field + fallback |
| Claim substantiation folder (evidence screenshots) | `claims.evidence_registry` with source, methodology, expiry |
| International compliance matrix (EU/UK/AU/CA rules) | `legal.regulations` with per-body versioning + geo-targeting |

---

## Real-World Usage

### 1. Agency Replaces PDF Contract with .m3m3tic

A marketing agency (Salvo Media) signs a client (Ring Concierge). Instead of a 10-page PDF, they produce a `.m3m3tic` file that:
- Defines exact Meta API operations the agency is authorized to perform
- Sets spend ceilings per platform with approval gates
- Maps deliverables (weekly reports, A/B tests, CRO audits) to verifiable outputs
- Encodes fee tiers ($5.5k at <$75k spend, scaling to $15k at >$1M)
- Auto-validates every ad creative against brand voice + FTC rules before publish

### 2. Affiliate Gets Machine-Enforced Compliance

An affiliate promoting health supplements gets a `.cr3st4n1` credential that:
- Binds their identity to their device (Ed25519 signed, hardware-fingerprinted)
- Grants `speech_authority` that blocks disease claims, income claims, and absolute terms
- Auto-injects FTC disclosure (`#ad`) on Instagram via `branded_content_sponsor_page_id`
- Blocks publish if content contains "cure", "miracle", or "guaranteed results"
- Triggers different disclosure formats per platform (YouTube: paid promotion checkbox, Blog: above-fold block)

### 3. International Brand Runs Ads Across 6 Jurisdictions

A brand targets US + EU + UK + Australia + Canada + China simultaneously. The `.m3m3tic` file:
- Applies GDPR consent rules when audience geo includes EU
- Blocks absolute terms ("best", "most") when targeting China (Article 9(3))
- Requires French version with 2x visual prominence when targeting Quebec
- Applies ASA "#ad as first word" rule for UK influencer content
- Auto-generates jurisdiction-specific disclaimers per audience segment
- Logs `policy_version` per regulatory body for audit trail

### 4. On-Chain Settlement Replaces Invoices

The M3M3TIC Protocol on Base L2:
- Auto-settles agency fees in USDC based on verified ad spend tier
- Splits affiliate commissions (10% protocol + X% affiliate + remainder to vendor)
- Records deliverable proofs as Merkle roots (zero-cost on-chain verification)
- Uses EIP-712 signed referral events from the Bonfire daemon
- No invoices, no ACH delays, no payment disputes

### 5. AI Content Gets Provenance Metadata

When AI generates ad copy or creative:
- `provenance.c2pa` section records the generation method
- Machine-readable watermark satisfies EU AI Act Article 50 (Aug 2026)
- Visible label satisfies China Deep Synthesis Provisions (GB 45438-2025)
- FTC disclosure guidance satisfied via `disclosures.renderings.*.ai_generated`
- Audit trail proves compliance retroactively

---

## The Position

**.m3m3tic is the universal translation layer between:**

| System | What it does | .m3m3tic mapping |
|---|---|---|
| Russia erid (ORD API) | Mandatory machine-readable ad token | `platforms.yandex.erid_token` |
| China GB 45438-2025 | AI content metadata standard | `provenance.c2pa` + `disclosures.renderings.*.ai_generated` |
| EU AI Act Article 50 | Machine-readable AI labeling | `provenance.c2pa.assertions.ai_generation_disclosure` |
| EU DSA Ad Repository | Transparency + targeting disclosure | `platforms.meta.targeting` + `disclosures.dsa_transparency` |
| IAB OpenRTB / AdCOM | Cross-platform ad object model | `platforms.*` field structure |
| Meta Marketing API | Campaign/creative/targeting objects | `platforms.meta.*` (direct field mapping) |
| Google Ads API | Campaign/ad group/ad resources | `platforms.google_ads.*` |
| FTC Endorsement Guides | Disclosure requirements | `disclosures.definitions.ftc_endorsement` |
| ASA CAP Code | UK ad disclosure format | `disclosures.renderings.*.asa_ad_label` |
| AANA Code (Australia) | Influencer disclosure | `disclosures.definitions` + `legal.regulations.accc` |

**One file. Every platform. Every jurisdiction. Machine-verifiable.**

---

## Status

| Component | Version | Status |
|---|---|---|
| Specification | 0.2.0 | Draft |
| JSON Schema | 0.1.0 | Released |
| Reference Examples | 3 | Available |
| OPA Policy Packs | 3 | Draft (7 international packs planned) |
| Restriction Algebra | 0.2.0 | Draft |
| International Support | 0.2.0 | 7 jurisdictions (US, EU, UK, RU, CN, AU, CA) |

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
- **Legal compliance** — FTC, FDA, GDPR, DSA, ASA, ACCC, PIPL, erid — versioned per regulatory body
- **Platform rules** — Meta Ads API fields, Google Ads resources, TikTok creative specs
- **Actor authorization** — Who can say what, spend what, on which platform (via .cr3st4n1)
- **Claim substantiation** — Evidence registry with source, methodology, expiry dates
- **Disclosure rendering** — Per-platform, per-jurisdiction disclosure format (API fields + fallbacks)

## The Restriction Algebra

When multiple rule sets apply (brand + actor + platform + jurisdiction), they compose via **set intersection** — the most restrictive rule always wins:

```
effective_policy = brand_authority ∩ speech_authority ∩ actor_restrictions ∩ platform_rules ∩ jurisdiction_rules
```

| Field Type | Composition | Example |
|---|---|---|
| Allowlists | INTERSECT | Brand allows [SHOP_NOW, LEARN_MORE], actor allows [LEARN_MORE] → effective = [LEARN_MORE] |
| Blocklists | UNION (append) | Brand blocks ["cure"], China blocks ["best"] → effective = ["cure", "best"] |
| Ceilings | MIN | Brand: $500k/mo, actor: $300k/mo → effective = $300k/mo |
| Booleans | OR (any=true → blocked) | Brand: disclosure=false, FTC: disclosure=true → required |

## Licensing

- **Specification & Schema**: Apache 2.0 (this repository)
- **Bonfire Terminal Validator**: BSL 1.1 (separate repository)
- **Read-only Parser SDK**: Apache 2.0 (separate repository, coming soon)

See [LICENSE](LICENSE) for details.

## Governance

This specification is maintained by [Bonfire Terminal](https://bonfire.dev). See [GOVERNANCE.md](GOVERNANCE.md) for the decision-making process.

## Implementations

See [IMPLEMENTATIONS.md](IMPLEMENTATIONS.md) for tools that support the `.m3m3tic` format.

---

## On-Chain Protocol

The M3M3TIC brand standard is enforced on-chain via three Solidity contracts deployed on Base L2:

| Contract | Purpose | Repo |
|----------|---------|------|
| `M3M3TICProtocol` | Core 3-way affiliate split + EIP-712 verified sale (USDC) | [bonfire-contracts](https://github.com/johncrestani1/bonfire-contracts) |
| `M3M3TICCredential` | Soulbound affiliate NFT (ERC-721 + ERC-5192) with auto-tier promotion | [bonfire-contracts](https://github.com/johncrestani1/bonfire-contracts) |
| `M3M3TICAudit` | Merkle-root payout audit trail (zero-cost on-chain verification) | [bonfire-contracts](https://github.com/johncrestani1/bonfire-contracts) |

**How `.m3m3tic` connects to on-chain:**

1. A `.m3m3tic` brand file defines what content an affiliate can create
2. A `.cr3st4n1` credential authorizes the affiliate (identity + device binding)
3. The Bonfire daemon signs referral events using EIP-712 (alloy compile-time ABI binding)
4. `M3M3TICProtocol.sol` verifies signatures on-chain and splits payments automatically

**Protocol constants** (immutable in bytecode):
- Protocol fee: 1000 BPS (10%) — M3M3TIC treasury, forever
- Max affiliate: 4000 BPS (40%) — Diamond tier ceiling
- Settlement: USDC on Base L2
- Signature expiry: 86,400 seconds (24 hours)

## Analogies

| Standard | Domain | What it did |
|---|---|---|
| PDF | Documents | Made documents portable and legally binding |
| Docker/OCI | Infrastructure | Made deployments reproducible and universal |
| SSL/TLS | Security | Made web communication trustworthy |
| SWIFT MT/MX | Finance | Made cross-border payments standardized |
| **.m3m3tic** | **Marketing** | **Makes commercial speech compliant, portable, and machine-verifiable** |

## Related Repositories

| Repo | Purpose |
|------|---------|
| [bonfire-terminal](https://github.com/johncrestani1/bonfire-terminal) | Desktop app + Rust daemon (signs referrals, validates compliance) |
| [bonfire-contracts](https://github.com/johncrestani1/bonfire-contracts) | CDD schemas + Solidity contracts (on-chain settlement) |
| [bonfire-dashboard](https://github.com/johncrestani1/bonfire-dashboard) | CI orchestrator + observability stack |
| [cr3st4n1](https://github.com/johncrestani1/cr3st4n1) | Credential format spec (.cr3st4n1 — actor authorization) |
