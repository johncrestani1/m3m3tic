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

## Related Repositories

| Repo | Purpose |
|------|---------|
| [bonfire-terminal](https://github.com/johncrestani1/bonfire-terminal) | Desktop app + Rust daemon (signs referrals) |
| [bonfire-contracts](https://github.com/johncrestani1/bonfire-contracts) | CDD schemas + Solidity contracts |
| [bonfire-dashboard](https://github.com/johncrestani1/bonfire-dashboard) | CI orchestrator + observability stack |
| [cr3st4n1](https://github.com/johncrestani1/cr3st4n1) | Credential format spec (.cr3st4n1) |
