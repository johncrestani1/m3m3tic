# Affiliate Platform Rosetta Stone

**.m3m3tic as the universal affiliate offer definition across Impact.com, CAKE, and TUNE/HasOffers**

---

## The Mapping

A single `.m3m3tic` `relationships[]` entry maps to native objects on all three platforms:

| .m3m3tic Field | Impact.com | CAKE | TUNE/HasOffers |
|---|---|---|---|
| `relationships[].actor_ref` | MediaPartnerId | affiliate_id | Affiliate.id |
| `relationships[].actor_name` | Partner.company | affiliate_name | Affiliate.company |
| `relationships[].type` | Contract type (partner/media) | Campaign (junction) | Offer-Affiliate approval |
| `relationships[].status` | Contract.Status | offer_status_id | Offer.status |
| `relationships[].compensation.model` | EventPayouts type | price_format_id | Offer.payout_type |
| `relationships[].compensation.rate` | DefaultPayoutRate | payout (%) | Offer.percent_payout |
| `relationships[].compensation.currency` | TemplateTerms.Currency | currency_id | Offer.currency |
| `relationships[].compensation.cookie_duration_days` | (attribution window) | click_cookie_days | Offer.session_hours / 24 |
| `relationships[].compensation.attribution` | (multi-touch model) | last_touch / click_trumps_impression | (session-based) |
| `relationships[].compensation.tiers[]` | ParentTier + RevenueThreshold | Volume-Based Tiers (VBT) | AffiliateTier + tiered_payout |
| `relationships[].compensation.caps.daily` | Limits(Period=DAY) | conversion_cap (daily) | Offer.conversion_cap |
| `relationships[].compensation.caps.monthly` | Limits(Period=MONTH) | (custom cap) | Offer.monthly_conversion_cap |
| `relationships[].compensation.caps.lifetime` | Limits(Period=CONTRACT_DURATION) | (custom cap) | Offer.lifetime_conversion_cap |
| `relationships[].authority.platforms[]` | MediaPartnerGroups | allowed_media_type_ids | Tags / OfferGroups |
| `relationships[].duration.start` | Contract.StartDate | (implicit) | Offer.create_date_utc |
| `relationships[].duration.end` | Contract.EndDate | expiration_date | Offer.expiration_date |
| `relationships[].provenance.contract_provider` | "impact" | "cake" | "tune" |
| `entity` (brand) | CampaignId / Brand | advertiser_id / Advertiser | Offer.advertiser_id / Advertiser |
| `legal.jurisdictions` | PayoutGroup Rules (CUSTOMER_COUNTRY) | country_codes + geo_targets | enforce_geo_targeting + country rules |
| `disclosures` | (external) | restrictions text field | Offer.terms_and_conditions |

---

## Payout Model Mapping

| .m3m3tic `compensation.model` | Impact.com | CAKE `price_format_id` | TUNE `payout_type` |
|---|---|---|---|
| `commission` (flat) | SALE / LEAD EventCategory | 1 (CPA) | `cpa_flat` |
| `commission` (percentage) | PayoutRate field | received_percentage=on | `cpa_percentage` |
| `commission` (hybrid) | Payout + PayoutRate | — | `cpa_both` |
| `cpc` | CLICK EventCategory | 2 (CPC) | `cpc` |
| `cpm` | — | 3 (CPM) | `cpm` |
| `flat_fee` | — | 4 (Fixed) | — |
| `retainer` | — | — | — |
| `gifted` | — | — | — |
| `unpaid` | — | — | — |

---

## Status Mapping

| .m3m3tic `relationships[].status` | Impact.com | CAKE | TUNE |
|---|---|---|---|
| `active` | Contract active | offer_status_id=1 (Public) | `active` |
| `paused` | Contract paused | offer_status_id=4 (Inactive) | `paused` |
| `terminated` | Contract terminated | (removed) | `deleted` |
| `expired` | Contract expired | (past expiration_date) | `expired` |
| (pending) | Awaiting signature | offer_status_id=3 (Apply To Run) | `pending` |

---

## Approval Mode Mapping

| .m3m3tic Concept | Impact.com | CAKE | TUNE |
|---|---|---|---|
| Open (auto-approve) | Auto-contract on acceptance | offer_status_id=1 (Public) + auto_approve | `require_approval=false, is_private=false` |
| Requires approval | Requires BrandSignatory | offer_status_id=3 (Apply To Run) | `require_approval=true` |
| Private/invite-only | Direct contract issuance | offer_status_id=2 (Private) | `is_private=true` |

---

## Traffic Type / Platform Mapping

| .m3m3tic `authority.platforms[]` | Impact.com | CAKE `media_type_id` | TUNE |
|---|---|---|---|
| `"blog"` | Content partner | (Other) | Tag/Group |
| `"youtube"` | Video partner | — | Tag/Group |
| `"instagram"` | Social partner | — | Tag/Group |
| `"email"` | Email partner | 3 (Email) | Tag/Group |
| `"search"` | Search partner | (Search) | Tag/Group |
| `"display"` | Display partner | 7 (Banner) | Tag/Group |
| `"mobile"` | Mobile partner | 42 (Mobile) | Tag/Group |
| `"podcast"` | Content partner | (Other) | Tag/Group |
| `"tiktok"` | Social partner | — | Tag/Group |

---

## Geographic Targeting Mapping

| .m3m3tic | Impact.com | CAKE | TUNE |
|---|---|---|---|
| `legal.jurisdictions[].id` | PayoutGroup Rules: CUSTOMER_COUNTRY operator | country_codes (allow/deny) + redirect_offer_contract_ids | enforce_geo_targeting + country rules |
| Per-country payout variation | PayoutGroup conditional rules | Offer Contracts (per-geo pricing) | OfferConversionCap (per-affiliate per-geo) |

---

## Cap Management Mapping

| .m3m3tic Field (proposed) | Impact.com | CAKE | TUNE |
|---|---|---|---|
| `compensation.caps.daily_conversions` | Limits(Type=ACTION, Period=DAY) | conversion_cap | conversion_cap |
| `compensation.caps.monthly_conversions` | Limits(Type=ACTION, Period=MONTH) | (cap_interval=monthly) | monthly_conversion_cap |
| `compensation.caps.lifetime_conversions` | Limits(Period=CONTRACT_DURATION) | (cap_interval=lifetime) | lifetime_conversion_cap |
| `compensation.caps.daily_payout` | Limits(Type=PAYOUT, Period=DAY) | — | payout_cap |
| `compensation.caps.monthly_payout` | Limits(Type=PAYOUT, Period=MONTH) | — | monthly_payout_cap |
| `compensation.caps.daily_clicks` | Limits(Type=CLICKS, Period=DAY) | click_cap | — |
| `compensation.caps.cap_behavior` | (always redirects) | conversion_cap_behavior (0-5) | (always pauses) |

---

## Sub-Affiliate / Delegation Mapping

| .m3m3tic Concept | Impact.com | CAKE | TUNE |
|---|---|---|---|
| Delegation chains (ADR-011) | PARTNER_REFERRAL EventCategory | s1 param (sub-affiliate) + directed campaigns | Affiliate.referral_id + AffiliateTier |
| `authority.can_delegate` | Contract allows sub-partners | (network manages sub-affiliates) | (built-in referral commission) |
| `authority.delegation_depth` | (single level referral) | (directed campaign = 1 level) | (AffiliateTier = 1 level) |
| Sub-ID tracking | SharedId + custom fields | s1-s5 URL params | affiliate_info1-5 |

---

## Tracking / Attribution Mapping

| .m3m3tic Field (proposed) | Impact.com | CAKE | TUNE |
|---|---|---|---|
| `impact.tracking_link` | Tracking link URL | Click URL (?a=&c=&s1=) | Tracking link URL |
| `impact.partner_id` | MediaPartnerId | affiliate_id | Affiliate.id |
| `impact.campaign_id` | CampaignId | offer_id | Offer.id |
| `impact.program_id` | ProgramId | — | — |
| `compensation.cookie_duration_days` | (attribution window) | click_cookie_days | session_hours / 24 |
| `compensation.attribution` | Multi-touch / last-click | last_touch + click_trumps_impression | (session-based) |

---

## Creative / Content Mapping

| .m3m3tic Concept | Impact.com | CAKE `creative_type_id` | TUNE `OfferFile.type` |
|---|---|---|---|
| `authority.operations: ["organic_post.create"]` | (content partner) | — | — |
| `authority.operations: ["referral_link.generate"]` | Tracking link generation | Click URL generation | Tracking link generation |
| Image creative | Ad creative (banner) | 3 (Image) | `image banner` |
| Video creative | Ad creative (video) | 7 (Video) | — |
| Text/link creative | Text link | 1 (Link) / 5 (Text) | `text ad` |
| Email creative | Email template | 2 (Email) | `email creative` |
| HTML creative | — | 6 (HTML) | `html ad` |

---

## Fraud / Compliance Mapping

| .m3m3tic Concept | Impact.com | CAKE | TUNE |
|---|---|---|---|
| `.cr3st4n1` trust level | (partner vetting) | affiliate_tier_id + review | Affiliate.fraud_risk_tier (0-4) |
| Policy pack evaluation | (external) | restrictions text + fraud integrations | Offer.terms_and_conditions |
| Content compliance | (manual review) | allow_affiliates_to_create_creatives | creative status (active/pending/deleted) |
| Fraud detection | Built-in | IPQS / Forensiq / Anura integrations | Built-in fraud scoring |

---

## What .m3m3tic Adds (Not in ANY Platform)

| .m3m3tic Exclusive | Why It Matters |
|---|---|
| `brand.voice` + `brand.terminology` | No platform enforces brand voice compliance |
| `legal.jurisdictions[]` + policy packs | No platform does multi-jurisdiction regulatory evaluation |
| `claims.evidence_required` | No platform validates claim substantiation |
| `disclosures.platform_renderings` | No platform auto-generates per-platform disclosure format |
| `.cr3st4n1` identity verification | No platform does hardware-bound cryptographic identity |
| `relationships[].authority.brand_voice` | No platform distinguishes speech authority from spend authority |
| `content.medium.mode: "live"` | No platform has live-content-specific compliance rules |
| On-chain settlement (M3M3TIC Protocol) | No platform does trustless USDC settlement with Merkle audit |
| OPA/Rego policy evaluation | No platform does programmatic multi-jurisdiction compliance checking |

**This is the moat.** Impact, CAKE, and TUNE handle tracking and payments. .m3m3tic handles compliance, identity, and brand enforcement — the layer they all lack.

---

## Integration Architecture

```
.m3m3tic (brand + relationships + compliance)
    │
    ├── → Impact.com API (create Contract, set PayoutGroups, configure Rules)
    ├── → CAKE API (addedit Offer, set Caps, configure GeoTargets)
    └── → TUNE API (create Offer, setAffiliateApproval, setGeoTargeting)

.cr3st4n1 (identity + verification)
    │
    ├── → Impact.com (MediaPartner onboarding)
    ├── → CAKE (Signup Affiliate API)
    └── → TUNE (Affiliate create)

Policy evaluation (OPA/Rego)
    │
    └── → ALL platforms (content validation BEFORE posting, independent of platform)
```

One `.m3m3tic` file → three platform configurations generated. One `.cr3st4n1` → three platform registrations. Compliance evaluation runs INDEPENDENTLY of all three platforms — it's the layer above.
