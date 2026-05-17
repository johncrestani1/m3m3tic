# .m3m3tic Ecosystem Architecture v0.2.0

**Status**: Draft
**Date**: 2026-05-17
**Authors**: Bonfire Terminal

---

## 1. Two File Types. That's It.

| File | Purpose |
|---|---|
| `.m3m3tic` | Brand + relationships + policy declarations. Everything about the brand and who can act on its behalf. |
| `.cr3st4n1` | Actor identity + credential. Who this person is, verified and hardware-bound. |

No `.m3m3tic-sow`. No third file type. Relationships live INSIDE the `.m3m3tic` file as scoped modules referencing `.cr3st4n1` credentials.

---

## 2. Design Principles

1. **Two files** — `.m3m3tic` (the brand) and `.cr3st4n1` (the person)
2. **Jurisdiction-neutral base** — no regulator's logic baked into schema
3. **Policy packs are external** — OPA/Rego files, versioned per regulatory body
4. **Context-complete evaluation** — never evaluate content, actor, or role in isolation
5. **Emergent composition** — "most restrictive wins" emerges from running all applicable policies

```
ALLOW/DENY = f(actor, relationship, brand, content, medium, claims, platform, jurisdiction[])
```

---

## 3. .m3m3tic File (Brand + Relationships + Policy Declarations)

```yaml
m3m3tic:
  version: "0.2.0"
  created_at: "2026-05-17T00:00:00Z"
  generator:
    tool: "Bonfire Terminal"
    version: "2.7.246"

# ─────────────────────────────────────────────────────────
# ENTITY — Who owns this brand
# ─────────────────────────────────────────────────────────
entity:
  legal_name: "Ring Concierge LLC"
  brand_name: "Ring Concierge"
  domain: "ringconcierge.com"
  jurisdiction: "US"
  operating_jurisdictions: ["US", "GB", "EU", "AU", "CA"]
  registrations:
    us_ein: "XX-XXXXXXX"
  industry:
    iab_content_taxonomy_id: "552"
    iab_ad_product_taxonomy_id: "1058"

# ─────────────────────────────────────────────────────────
# BRAND — Voice, visual, terminology, platform config
# ─────────────────────────────────────────────────────────
brand:
  voice:
    personality: "Elegant, confident, warm. Never loud or desperate."
    primary_tone: "elegant"
    secondary_tones: ["confident", "warm"]
    avoided_tones: ["casual", "loud", "desperate", "salesy"]
    formality_level: "high"
    uses_contractions: false
    context_overrides:
      social: { tone: "warm", formality_level: "medium" }
      ad: { tone: "direct", formality_level: "high" }
    good_examples:
      - "Handcrafted for the moment that changes everything."
    bad_examples:
      - "BUY NOW!!! BEST RINGS EVER!!!"

  terminology:
    preferred_terms:
      - { preferred: "handcrafted", alternatives: ["handmade", "artisan"] }
      - { preferred: "engagement ring", alternatives: ["diamond ring"] }
    prohibited_terms:
      - { term: "cheap", reason: "conflicts with luxury positioning" }
      - { term: "discount", reason: "brand does not discount" }
    brand_name_casing: "Ring Concierge"
    product_names:
      "Whisper Thin": "Whisper Thin"
      "Icon": "Icon"

  visual:
    primary_colors: ["#1a1a2e", "#c9a96e"]
    secondary_colors: ["#ffffff", "#f5f5f5"]
    accent_colors: ["#e8d5b7"]
    forbidden_colors: ["#FF0000", "#00FF00"]
    logo_url: "assets/logo.svg"
    fonts:
      primary: { family: "Cormorant Garamond", weight: [400, 600] }
      secondary: { family: "Montserrat", weight: [300, 400, 500] }

  platform_config:
    meta:
      account:
        business_id: "..."
        ad_account_id: "act_..."
        page_id: "..."
        instagram_account_id: "..."
      campaign:
        objectives_allowed: [OUTCOME_SALES, OUTCOME_LEADS, OUTCOME_TRAFFIC]
        special_ad_categories: ["NONE"]
        default_status: PAUSED
      creative:
        primary_text: { max_length: 125 }
        headline: { max_length: 40 }
        cta_allowed: [SHOP_NOW, LEARN_MORE, BOOK_NOW]
        formats_allowed: [SINGLE_IMAGE, SINGLE_VIDEO, CAROUSEL]
      validation:
        dry_run_required: true

    google_ads:
      account:
        customer_id: "..."
      campaign:
        channel_types_allowed: [SEARCH, SHOPPING, PERFORMANCE_MAX, DEMAND_GEN]
        bidding_strategies_allowed: [TARGET_ROAS, MAXIMIZE_CONVERSION_VALUE]

    tiktok:
      account:
        advertiser_id: "..."
      campaign:
        objectives_allowed: [WEB_CONVERSIONS, PRODUCT_SALES]
      creative:
        formats_allowed: [SINGLE_VIDEO, SPARK_ADS]

# ─────────────────────────────────────────────────────────
# RELATIONSHIPS — Who acts on behalf of this brand
# ─────────────────────────────────────────────────────────
relationships:
  - actor_ref: "sha256:abc123..."       # hash of .cr3st4n1 file
    actor_name: "Salvo Media LLC"
    type: "agency"
    compensation:
      model: "tiered_retainer"
      currency: "USD"
      tiers:
        - { ceiling: 75000, fee: 5500 }
        - { ceiling: 125000, fee: 7000 }
        - { ceiling: 200000, fee: 8500 }
        - { ceiling: 300000, fee: 10500 }
        - { ceiling: 500000, fee: 12500 }
        - { ceiling: 1000000, fee: 14000 }
        - { ceiling: null, fee: 15000 }
      payment:
        timing: "prepaid_monthly"
        methods: ["ach", "wire", "check"]
    authority:
      brand_voice: true                  # can write copy as the brand
      spend: true                        # can allocate budget
      create_assets: true                # can produce new creative
      comparative_claims: true           # can reference competitors
      live_video: true
      platforms: ["meta", "google_ads", "tiktok", "pinterest", "snap"]
      operations:
        granted:
          - "campaign.create"
          - "campaign.update"
          - "adset.create"
          - "adset.update"
          - "adcreative.create"
          - "adcreative.update"
          - "adcreative.delete"
          - "insights.read"
          - "pixel.manage"
          - "audience.create"
        withheld:
          - "campaign.delete"
          - "account.settings"
          - "billing.modify"
      spend_ceiling_monthly: 500000
      spend_ceiling_daily: 25000
      approval_threshold: 10000
    duration:
      start: "2025-03-01"
      end: null
      notice_days: 30
    approvals:
      - { operation: "campaign.create", requires: "principal_written" }
      - { operation: "campaign.activate", requires: "principal_written" }
    communication:
      channels: ["slack", "email"]
      reporting: "weekly"
    provenance:
      contract_provider: "docusign"
      envelope_id: "8FF7D57C-DD8B-4385-88C1-311D8BA7AE03"
      signed_at: "2025-03-13"
    status: "active"

  - actor_ref: "sha256:def456..."
    actor_name: "Maria Gonzalez"
    type: "affiliate"
    compensation:
      model: "commission"
      rate: 0.15
      currency: "USD"
    authority:
      brand_voice: false                 # must use own voice
      spend: false                       # cannot buy ads
      create_assets: false               # must use provided assets
      comparative_claims: false
      live_video: "conditional"          # requires approval
      platforms: ["instagram", "tiktok", "blog"]
      operations:
        granted:
          - "organic_post.create"
          - "story.create"
        withheld:
          - "campaign.create"
          - "adcreative.create"
      spend_ceiling_monthly: 0
    duration:
      start: "2026-01-15"
      end: null
      notice_days: 7
    status: "active"

# ─────────────────────────────────────────────────────────
# LEGAL — Jurisdiction declarations + policy pack refs
# ─────────────────────────────────────────────────────────
legal:
  jurisdictions:
    - id: "US"
      policy_packs:
        - "ftc-endorsement-guides-2024.1"
        - "fda-dshea"
    - id: "EU"
      policy_packs:
        - "eu-dsa-ad-transparency-2024"
        - "eu-ai-act-article50-2026"
        - "gdpr-consent-tracking"
    - id: "GB"
      policy_packs:
        - "asa-cap-code-ed12"
        - "uk-gdpr-2025"
        - "hfss-advertising-ban"
    - id: "RU"
      policy_packs:
        - "ru-ord-erid-marking-347fz"
        - "ru-advertising-law-38fz"
    - id: "CN"
      policy_packs:
        - "cn-advertising-law-absolute-terms"
        - "cn-deep-synthesis-ai-labeling"
        - "cn-gb45438-metadata"
    - id: "AU"
      policy_packs:
        - "au-acl-section18"
        - "au-aana-code-disclosure"
    - id: "CA"
      policy_packs:
        - "ca-competition-act-74.01"
        - "ca-casl"
        - "ca-quebec-french-language"

# ─────────────────────────────────────────────────────────
# DISCLOSURES — Platform-specific rendering hints
# ─────────────────────────────────────────────────────────
disclosures:
  platform_renderings:
    instagram:
      branded_content:
        method: "platform_toggle"
        api_field: "branded_content_sponsor_page_id"
        value: "{{brand.platform_config.meta.account.page_id}}"
      ad_label:
        method: "caption_prefix"
        text: "#ad"
        position: "first_word"
    youtube:
      branded_content:
        method: "paid_promotion_checkbox"
        api_field: "paidProductPlacementDetails.hasPaidProductPlacement"
        value: true
    tiktok:
      branded_content:
        method: "branded_content_toggle"
        api_field: "is_branded_content"
        value: true
    yandex:
      erid:
        method: "url_parameter"
        format: "?erid={token}"
      advertising_label:
        method: "text_overlay"
        text: "реклама"
    wechat:
      ai_label:
        method: "platform_label"
        text: "AI生成内容"

_signature:
  algorithm: "Ed25519"
  signed_at: "2026-05-17T00:00:00Z"
  signature: "base64:..."
```

---

## 4. .cr3st4n1 File (Actor Identity + Credential)

Pure identity. No brand info. No permissions. No jurisdiction logic.

```yaml
cr3st4n1:
  version: "0.4.0"
  created_at: "2026-05-17T00:00:00Z"
  generator:
    tool: "Bonfire Terminal"
    version: "2.7.246"

identity:
  display_name: "Art Villalobos"
  email: "art@salvomedia.com"
  organization: "Salvo Media LLC"
  verification:
    level: "contract"
    providers:
      - type: "e_signature"
        provider: "hellosign"
        signature_request_id: "abc123"
        signed_at: "2026-05-17T09:00:00Z"
      - type: "membership"
        provider: "circle"
        community_id: "363417"
        tier: "mentorship"
        tag_id: "246372"
        verified_at: "2026-05-17T09:30:00Z"

device:
  binding_level: "fingerprinted"
  hardware_fingerprint: "sha256:..."
  registered_at: "2026-05-17T10:00:00Z"

trust:
  level: 3
  credential_chain:
    - issuer: "Bonfire Terminal"
      issued_at: "2026-05-17T10:00:00Z"
      method: "hellosign+circle dual-gate"

_signature:
  algorithm: "Ed25519"
  signed_at: "2026-05-17T10:00:00Z"
  signature: "base64:..."
```

---

## 5. Content Object (Runtime, Not Persisted)

Constructed at evaluation time. Represents a single piece of content being validated.

```yaml
content:
  id: "content_abc123"
  created_at: "2026-05-17T14:00:00Z"
  created_by: "sha256:..."            # actor's .cr3st4n1 hash

  medium:
    platform: "meta"
    placement: "instagram_feed"
    format: "SINGLE_IMAGE"
    operation: "adcreative.create"

  creative:
    primary_text: "Handcrafted engagement rings, designed just for you."
    headline: "Ring Concierge"
    cta: "SHOP_NOW"
    media_refs:
      - { type: "image", hash: "sha256:..." }

  claims:
    - id: "claim_001"
      type: "factual"
      text: "Over 10,000 happy customers"
      category: "social_proof"
      evidence:
        - source: "shopify_orders"
          type: "internal_data"
          value: 12847
          as_of: "2026-05-01"

  disclosures_attached: []            # empty until evaluation says what's needed

  provenance:
    ai_generated: false
    ai_assisted: true
    human_reviewed: true

  audience:
    geos: ["US", "GB"]
    age_min: 25
    age_max: 55

  spend_amount: 5000                  # USD, if applicable
```

---

## 6. Policy Packs (Jurisdiction Layer)

External OPA/Rego files. Never in the base schema. Versioned per regulatory body.

### Structure

```
policies/
├── us/
│   ├── ftc-endorsement-guides-2024.1.rego
│   ├── fda-dshea.rego
│   └── metadata.yaml
├── eu/
│   ├── dsa-ad-transparency-2024.rego
│   ├── ai-act-article50-2026.rego
│   ├── gdpr-consent-tracking.rego
│   └── metadata.yaml
├── gb/
│   ├── asa-cap-code-ed12.rego
│   ├── hfss-advertising-ban.rego
│   └── metadata.yaml
├── ru/
│   ├── ord-erid-marking-347fz.rego
│   ├── advertising-law-38fz.rego
│   └── metadata.yaml
├── cn/
│   ├── advertising-law-absolute-terms.rego
│   ├── deep-synthesis-ai-labeling.rego
│   ├── gb45438-metadata.rego
│   └── metadata.yaml
├── au/
│   ├── acl-section18.rego
│   ├── aana-code-disclosure.rego
│   └── metadata.yaml
├── ca/
│   ├── competition-act-74.01.rego
│   ├── quebec-french-language.rego
│   ├── casl.rego
│   └── metadata.yaml
└── industry/
    ├── iab-tcf-consent.rego
    ├── iab-openrtb-brand-safety.rego
    └── metadata.yaml
```

### Policy Pack Metadata

```yaml
# policies/cn/metadata.yaml
jurisdiction: "CN"
body: "State Administration for Market Regulation"
pack_id: "cn-advertising-law-absolute-terms"
policy_version: "2023.1"
effective_date: "2023-03-20"
source: "SAMR Document No. 6 (2023)"
maintainer: "bonfire-policy-team"
```

### Example Policy: Evaluates Full Context

```rego
package m3m3tic.policy.cn.absolute_terms

import future.keywords.in

# Self-selects based on audience geo
applicable {
  "CN" in input.content.audience.geos
}

banned_terms := {
  "best", "most", "first", "only", "top", "unprecedented",
  "最佳", "最好", "第一", "唯一", "顶级", "极品", "国家级", "最高级"
}

deny[result] {
  applicable
  term := banned_terms[_]
  contains(lower(input.content.creative.primary_text), lower(term))
  result := {
    "rule": "cn-advertising-law-article-9-3",
    "severity": "block",
    "message": sprintf("Absolute term '%s' banned under PRC Advertising Law", [term]),
    "jurisdiction": "CN"
  }
}
```

```rego
package m3m3tic.policy.ru.erid

import future.keywords.in

applicable {
  "RU" in input.content.audience.geos
  input.content.medium.platform in {"yandex", "vk", "mytarget", "telegram"}
}

deny[result] {
  applicable
  not has_erid
  result := {
    "rule": "ru-347fz-erid",
    "severity": "block",
    "message": "Internet advertising in RU requires erid token (347-FZ)",
    "jurisdiction": "RU"
  }
}

has_erid {
  some d in input.content.disclosures_attached
  d.type == "erid_marking"
  d.token != null
}
```

---

## 7. Evaluation Function

### Input Assembly

```json
{
  "actor": { /* .cr3st4n1 content (identity, device, trust) */ },
  "relationship": { /* matched entry from .m3m3tic relationships[] */ },
  "brand": { /* .m3m3tic brand section (voice, terminology, visual, platform_config) */ },
  "content": { /* runtime content object */ },
  "legal": { /* .m3m3tic legal section (jurisdiction declarations) */ }
}
```

### Evaluation Steps

```
1. Load actor's .cr3st4n1 → verify signature + device binding
2. Load brand's .m3m3tic → find relationship matching actor_ref
3. If no matching relationship → DENY ("actor not authorized for this brand")
4. If relationship.status != "active" → DENY ("relationship expired/terminated")
5. Construct evaluation input from all layers
6. Determine applicable jurisdictions from content.audience.geos ∩ legal.jurisdictions
7. Load all policy packs referenced in applicable jurisdictions
8. Run ALL applicable policies against full context
9. Collect results:
   - Any "block" severity → DENY (content cannot publish)
   - Any "warn" severity → WARN (content can publish with flag)
   - All pass → ALLOW
```

### What Is Never Evaluated in Isolation

| Bad (isolated) | Good (full context) |
|---|---|
| "Does this text contain 'best'?" | "Does this text contain 'best' AND target CN audience?" |
| "Is this actor an affiliate?" | "Is this actor an affiliate WITH commission compensation FOR this brand?" |
| "Is disclosure needed?" | "Is disclosure needed GIVEN actor type + compensation model + audience geo + platform?" |
| "Is this claim allowed?" | "Is this claim allowed GIVEN claim type + evidence + jurisdiction + actor authority?" |

---

## 8. How Relationships Work (Inside .m3m3tic)

The `.m3m3tic` file is the brand owner's document. They declare who can act on their behalf and with what authority.

### Relationship Types

| Type | Description | Typical authority |
|---|---|---|
| `employee` | Internal team member | Full brand_voice, spend, create |
| `agency` | Delegated operator | brand_voice: true, spend: true, scoped operations |
| `affiliate` | Commission promoter | brand_voice: false, spend: false, organic only |
| `influencer` | Paid content creator | brand_voice: false (own voice), spend: false |
| `reseller` | Authorized seller | brand_voice: limited, spend: own budget |
| `franchisee` | Licensed operator | brand_voice: true (within guidelines), spend: own |
| `advocate` | Organic unpaid supporter | brand_voice: false, spend: false |

### Authority Fields

```yaml
authority:
  brand_voice: true|false              # can speak AS the brand
  spend: true|false                    # can allocate ad budget
  create_assets: true|false            # can produce new creative
  comparative_claims: true|false       # can reference competitors
  live_video: true|false|"conditional" # can go live
  platforms: [...]                     # which platforms
  operations:
    granted: [...]                     # allowed API operations
    withheld: [...]                    # explicitly denied
  spend_ceiling_monthly: 500000        # max monthly spend (0 = cannot spend)
  spend_ceiling_daily: 25000           # max daily spend
  approval_threshold: 10000            # needs approval above this
```

### Matching Actor to Relationship

At evaluation time:
1. Compute SHA-256 hash of actor's `.cr3st4n1` file
2. Find `relationships[]` entry where `actor_ref` matches
3. If found → use that relationship's authority as context
4. If not found → DENY (unknown actor)

---

## 9. What Does NOT Exist

| Eliminated | Reason |
|---|---|
| `.m3m3tic-sow` | Absorbed into `.m3m3tic` relationships[] section |
| Restriction algebra declarations | Emerges from policy evaluation (all policies run, any deny = blocked) |
| Hardcoded FTC logic | Lives in `policies/us/ftc-endorsement-guides.rego` |
| Hardcoded disclosure requirements | Policy packs determine; renderings are reference data |
| Universal objective enum | Each platform speaks its native language |
| `speech_authority` / `spend_authority` as separate sections | Unified under `relationships[].authority` |
| Three-authority model | One `authority` object per relationship, policies interpret it |

---

## 10. File Lifecycle

```
Brand owner creates .m3m3tic:
  → defines brand (voice, visual, platforms)
  → declares relationships (who can do what)
  → lists operating jurisdictions + policy packs

Actor gets .cr3st4n1:
  → verified by Bonfire daemon (HelloSign + Circle dual-gate)
  → hardware-bound (Ed25519 signed)
  → pure identity (no permissions in this file)

Content is created:
  → actor uses Bonfire Terminal or platform tools
  → content object constructed at creation time
  → evaluator runs: loads .cr3st4n1, matches to .m3m3tic relationship,
    runs all jurisdiction policy packs
  → ALLOW → publish
  → DENY → blocked with remediation guidance
```
