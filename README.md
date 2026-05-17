# .m3m3tic

**The portable, machine-readable standard for brand identity + marketing compliance.**

> A `.m3m3tic` file describes everything needed to create on-brand, legally compliant marketing content: visual identity, voice guidelines, platform configuration, actor relationships, and jurisdiction declarations.

---

## Two File Types. That's It.

| File | Purpose |
|---|---|
| `.m3m3tic` | Brand + relationships + policy declarations |
| `.cr3st4n1` | Actor identity + credential |

No third file type. Relationships live inside `.m3m3tic` as scoped modules referencing `.cr3st4n1` credentials.

---

## Architecture

```
ALLOW/DENY = f(actor, relationship, brand, content, medium, claims, platform, jurisdiction[])
```

Five evaluation layers, two file types, external policy packs:

```
Jurisdiction Layer   (policy packs — OPA/Rego, external, pluggable)
Content Layer        (runtime object — what's being published)
Brand Layer          (.m3m3tic — voice, visual, platforms, relationships)
Relationship Layer   (.m3m3tic relationships[] — delegation, compensation, authority)
Identity Layer       (.cr3st4n1 — who the actor is, verified + hardware-bound)
```

**Design principles:**
- No jurisdiction logic in base schema (FTC, ASA, GDPR = policy packs)
- Never evaluate content in isolation
- Never evaluate actor role in isolation
- Composition emerges from "all policies run, any deny = blocked"

---

## What .m3m3tic Replaces

| Before (PDFs, tribal knowledge) | After (.m3m3tic) |
|---|---|
| Agency contract PDF | `relationships[]` with authority + spend ceilings |
| Brand guidelines PDF | `brand.voice` + `brand.visual` + `brand.terminology` |
| Platform ad specs | `brand.platform_config.meta.creative` |
| Compliance checklist | Policy packs per jurisdiction |
| Influencer disclosure memo | `disclosures.platform_renderings` |

---

## Example

```yaml
m3m3tic:
  version: "0.2.0"

entity:
  legal_name: "Ring Concierge LLC"
  brand_name: "Ring Concierge"
  operating_jurisdictions: ["US", "GB", "EU", "AU", "CA"]

brand:
  voice:
    primary_tone: "elegant"
    avoided_tones: ["casual", "loud", "desperate"]
  terminology:
    prohibited_terms:
      - { term: "cheap", reason: "conflicts with luxury positioning" }
  platform_config:
    meta:
      campaign:
        objectives_allowed: [OUTCOME_SALES, OUTCOME_LEADS]
      creative:
        cta_allowed: [SHOP_NOW, LEARN_MORE, BOOK_NOW]

relationships:
  - actor_ref: "sha256:abc123..."
    actor_name: "Salvo Media LLC"
    type: "agency"
    compensation:
      model: "tiered_retainer"
    authority:
      brand_voice: true
      spend: true
      spend_ceiling_monthly: 500000
      platforms: ["meta", "google_ads", "tiktok"]
    status: "active"

  - actor_ref: "sha256:def456..."
    actor_name: "Maria Gonzalez"
    type: "affiliate"
    compensation:
      model: "commission"
      rate: 0.15
    authority:
      brand_voice: false
      spend: false
      platforms: ["instagram", "tiktok", "blog"]
    status: "active"

legal:
  jurisdictions:
    - id: "US"
      policy_packs: ["ftc-endorsement-guides-2024.1"]
    - id: "CN"
      policy_packs: ["cn-advertising-law-absolute-terms", "cn-gb45438-metadata"]
    - id: "RU"
      policy_packs: ["ru-ord-erid-marking-347fz"]

disclosures:
  platform_renderings:
    instagram:
      branded_content:
        method: "platform_toggle"
        api_field: "branded_content_sponsor_page_id"
    yandex:
      erid:
        method: "url_parameter"
        format: "?erid={token}"
```

---

## The Position

.m3m3tic is the universal translation layer between:

| System | .m3m3tic mapping |
|---|---|
| Russia erid (ORD API) | `disclosures.platform_renderings.yandex.erid` |
| China GB 45438-2025 | `disclosures.platform_renderings.wechat.ai_label` |
| EU AI Act Article 50 | Policy pack: `eu/ai-act-article50-2026.rego` |
| EU DSA Ad Repository | Policy pack: `eu/dsa-ad-transparency-2024.rego` |
| IAB OpenRTB / AdCOM | `entity.industry.iab_*` taxonomy IDs |
| Meta Marketing API | `brand.platform_config.meta.*` (native enums) |
| Google Ads API | `brand.platform_config.google_ads.*` |
| FTC Endorsement Guides | Policy pack: `us/ftc-endorsement-guides-2024.1.rego` |
| ASA CAP Code | Policy pack: `gb/asa-cap-code-ed12.rego` |

One file. Every platform. Every jurisdiction. Machine-verifiable.

---

## Policy Packs (Jurisdiction Layer)

External OPA/Rego files. Never in the base schema. Versioned per regulatory body.

```
policies/
├── us/   ftc-endorsement-guides-2024.1.rego, fda-dshea.rego
├── eu/   dsa-ad-transparency-2024.rego, ai-act-article50-2026.rego, gdpr-consent.rego
├── gb/   asa-cap-code-ed12.rego, hfss-advertising-ban.rego
├── ru/   ord-erid-marking-347fz.rego, advertising-law-38fz.rego
├── cn/   advertising-law-absolute-terms.rego, gb45438-metadata.rego
├── au/   acl-section18.rego, aana-code-disclosure.rego
├── ca/   competition-act-74.01.rego, quebec-french-language.rego, casl.rego
└── industry/   iab-tcf-consent.rego, iab-openrtb-brand-safety.rego
```

---

## Repository Structure

```
spec/v0.2.0/           # The formal specification document
schemas/               # JSON Schema for validation (Draft 2020-12)
examples/              # Reference .m3m3tic files
policies/              # OPA/Rego jurisdiction policy packs
docs/                  # Taxonomy mappings, architecture docs
tests/                 # Valid/invalid test files
decisions/             # Architecture Decision Records
```

---

## On-Chain Protocol

| Contract | Purpose | Chain |
|----------|---------|-------|
| `M3M3TICProtocol` | 3-way affiliate split + EIP-712 verified sale (USDC) | Base L2 |
| `M3M3TICCredential` | Soulbound affiliate NFT (ERC-5192) with auto-tier | Base L2 |
| `M3M3TICAudit` | Merkle-root payout audit trail | Base L2 |

Protocol constants (immutable): 10% protocol fee, 40% max affiliate, USDC on Base, 24h signature expiry.

---

## Licensing

| Component | License |
|-----------|---------|
| Specification & Schema (this repo) | Apache 2.0 |
| Bonfire Terminal Validator | BSL 1.1 |
| Read-only Parser SDK | Apache 2.0 (coming) |

---

## Related Repositories

| Repo | Purpose |
|------|---------|
| [cr3st4n1](https://github.com/johncrestani1/cr3st4n1) | Actor identity credential (.cr3st4n1) |
| [bonfire-terminal](https://github.com/johncrestani1/bonfire-terminal) | Desktop app + Rust daemon |
| [bonfire-contracts](https://github.com/johncrestani1/bonfire-contracts) | Solidity contracts (on-chain settlement) |
