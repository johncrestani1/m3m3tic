# .m3m3tic File Format Specification v0.1.0

**Status**: Draft
**Date**: 2026-05-15
**Authors**: Bonfire Terminal

## 1. Introduction

The `.m3m3tic` file format is a YAML-based standard for encoding brand identity, legal compliance rules, platform-specific configuration, financial reporting mappings, and content provenance metadata in a single, portable, machine-readable document.

### 1.1 Goals

- **Portable**: A single file that moves with the brand across tools, agencies, and platforms
- **Validatable**: Structurally validated via JSON Schema, compliance-validated via OPA/Rego policies
- **Signable**: Supports cryptographic signatures proving validation by an authorized tool
- **Human-readable**: YAML format readable by brand managers, not just engineers
- **Machine-executable**: Directly maps to platform APIs (Meta Ads, Google Ads) and regulatory databases (FTC, FDA)

### 1.2 Non-Goals

- Replacing platform-specific campaign configuration (campaigns are built FROM the .m3m3tic file, not IN it)
- Storing creative assets (images, videos) — only references/URLs
- Real-time data (analytics, spend tracking) — only reporting taxonomy mappings

## 2. File Format

### 2.1 Encoding

- Files MUST be valid YAML 1.2
- Files MUST use UTF-8 encoding
- Files SHOULD use the `.m3m3tic` extension
- Files MUST contain exactly one YAML document (no multi-document streams)
- The MIME type is `application/x-m3m3tic+yaml` (provisional)

### 2.2 Top-Level Structure

A `.m3m3tic` file MUST contain a `m3m3tic` root key with a `version` field. All other top-level sections are OPTIONAL.

```yaml
m3m3tic:
  version: "0.1.0"

entity:       # Legal entity and business classification
brand:        # Visual identity, voice, terminology
platforms:    # Platform-specific configuration (Meta, Google, etc.)
legal:        # Regulatory compliance rules
reporting:    # Financial reporting taxonomy mappings
provenance:   # Content provenance and signing metadata
enforcement:  # Validation and enforcement configuration
```

## 3. Sections

### 3.1 `m3m3tic` (REQUIRED)

Format metadata. The only required section.

| Field | Type | Required | Description |
|---|---|---|---|
| `version` | string | YES | Spec version this file conforms to (semver) |
| `created_at` | datetime | no | ISO 8601 creation timestamp |
| `modified_at` | datetime | no | ISO 8601 last modification timestamp |
| `generator` | object | no | Tool that created/last modified this file |
| `generator.tool` | string | no | Tool name (e.g., "Bonfire Terminal") |
| `generator.version` | string | no | Tool version |

### 3.2 `entity` (OPTIONAL)

The legal entity that owns this brand identity.

| Field | Type | Required | Description |
|---|---|---|---|
| `legal_name` | string | no | Registered legal entity name |
| `brand_name` | string | no | Public-facing brand name |
| `domain` | string | no | Primary website domain |
| `jurisdiction` | string | no | Primary legal jurisdiction (ISO 3166-1 alpha-2) |
| `industry` | string | no | Industry classification |
| `vertical` | string | no | Business vertical (maps to Meta's CampaignGroupBrandConfiguration.vertical) |
| `category` | object | no | Primary business category |
| `category.id` | string | no | Platform category ID (e.g., Meta's Page.category ID) |
| `category.name` | string | no | Human-readable category name |
| `categories` | array[object] | no | Additional business categories |
| `price_range` | string | no | Price tier: `$`, `$$`, `$$$`, or `$$$$` |
| `franchise` | object | no | Franchise/chain configuration |
| `franchise.is_chain` | boolean | no | Whether this entity is part of a franchise |
| `franchise.global_brand_name` | string | no | Parent brand name |
| `franchise.partner_count` | integer | no | Number of franchise partners |

### 3.3 `brand` (OPTIONAL)

Brand identity tokens and guidelines.

#### 3.3.1 `brand.visual`

| Field | Type | Required | Description |
|---|---|---|---|
| `tokens` | object | no | DTCG-compatible design tokens |
| `primary_colors` | array[string] | no | Primary brand colors (hex). Maps to Meta BackgroundColor. |
| `secondary_colors` | array[string] | no | Secondary brand colors (hex). Maps to Meta TextColor. |
| `accent_colors` | array[string] | no | Accent colors (hex) |
| `forbidden_colors` | array[string] | no | Colors that must never be used (hex) |
| `logo_url` | string | no | Path or URL to primary logo |

#### 3.3.2 `brand.voice`

| Field | Type | Required | Description |
|---|---|---|---|
| `personality` | string | no | Free-text voice description |
| `primary_tone` | string | no | Primary tone word |
| `secondary_tones` | array[string] | no | Additional tone words |
| `avoided_tones` | array[string] | no | Tones to avoid |
| `uses_contractions` | boolean | no | Whether contractions are acceptable |
| `context_overrides` | object | no | Per-channel tone overrides (keys: social, email, ad, etc.) |
| `good_examples` | array[string] | no | Example copy that matches the voice |
| `bad_examples` | array[string] | no | Example copy that violates the voice |

#### 3.3.3 `brand.terminology`

| Field | Type | Required | Description |
|---|---|---|---|
| `preferred_terms` | array[object] | no | Preferred terminology with alternatives |
| `prohibited_terms` | array[object] | no | Terms that must never be used, with reasons |
| `product_names` | object | no | Canonical product name casing (key: informal, value: correct) |
| `brand_name_casing` | string | no | Correct casing for the brand name |
| `company_legal_name` | string | no | Full legal company name for disclaimers |

### 3.4 `platforms` (OPTIONAL)

Platform-specific configuration. Each key is a platform identifier.

#### 3.4.1 `platforms.meta`

Maps directly to Meta Marketing API fields.

| Field | Type | Description |
|---|---|---|
| `account.business_id` | string | Meta Business Manager ID |
| `account.ad_account_id` | string | Meta Ad Account ID |
| `account.page_id` | string | Facebook Page ID |
| `account.instagram_account_id` | string | Instagram Account ID |
| `campaign.objective_allowed` | array[string] | Allowed campaign objectives |
| `campaign.default_status` | string | Default campaign status (PAUSED recommended) |
| `campaign.special_ad_categories` | array[string] | Meta SpecialAdCategory values |
| `creative.primary_text.max_length` | integer | Max primary text length |
| `creative.headline.max_length` | integer | Max headline length |
| `creative.cta_allowed` | array[string] | Allowed call-to-action buttons |
| `creative.food_styles` | array[string] | Meta Page.FoodStyles enum values |
| `prohibited_patterns` | object | Content patterns to block |
| `validation.dry_run_required` | boolean | Whether dry-run is required before publish |
| `sponsor_page_id` | string | Branded content sponsor Page ID |
| `sponsor_relationship` | string | Partnership type classification |
| `endorsement_disclosure` | string | Branded content disclosure text |

### 3.5 `legal` (OPTIONAL)

Regulatory compliance rules organized by regulatory body.

#### 3.5.1 `legal.ftc`

| Field | Type | Description |
|---|---|---|
| `endorsement_guides.disclosure_required` | boolean | Whether FTC endorsement disclosure is required |
| `endorsement_guides.disclosure_terms` | array[string] | Acceptable disclosure terms ("ad", "sponsored", etc.) |
| `endorsement_guides.applies_to` | array[string] | Content types requiring disclosure |

#### 3.5.2 `legal.fda`

| Field | Type | Description |
|---|---|---|
| `health_claims.disease_claims_blocked` | boolean | Block disease cure/treat claims |
| `health_claims.required_disclaimer_id` | string | Reference to disclaimer in `legal.disclaimers` |
| `health_claims.blocked_patterns` | array[string] | Patterns that trigger FDA violations |

#### 3.5.3 `legal.income_claims`

| Field | Type | Description |
|---|---|---|
| `earnings_claims_require_disclosure` | boolean | Whether income claims need disclosure |
| `prohibited_patterns` | array[string] | Banned income claim patterns |

#### 3.5.4 `legal.privacy`

| Field | Type | Description |
|---|---|---|
| `pii_in_ad_copy_blocked` | boolean | Block PII in ad copy |
| `sensitive_attributes_blocked` | array[string] | Protected attribute categories |

#### 3.5.5 `legal.disclaimers`

Array of disclaimer objects.

| Field | Type | Description |
|---|---|---|
| `title` | string | Disclaimer identifier |
| `text` | string | Full disclaimer text |
| `url` | string | URL to full disclaimer page |

#### 3.5.6 `legal.required_disclosures`

Array of trigger-based disclosure rules.

| Field | Type | Description |
|---|---|---|
| `trigger` | string | Content keyword/topic that triggers the disclosure |
| `disclosure` | string | Required disclosure text |
| `regulation` | string | Regulatory citation |

#### 3.5.7 `legal.jurisdictions`

| Field | Type | Description |
|---|---|---|
| `jurisdictions` | array[string] | ISO 3166-1 alpha-2 country codes where this brand operates |
| `regional_disclaimers` | object | Per-jurisdiction disclaimer requirements (key: country code) |

### 3.6 `reporting` (OPTIONAL)

Financial reporting taxonomy mappings.

#### 3.6.1 `reporting.xbrl`

| Field | Type | Description |
|---|---|---|
| `taxonomy_namespace` | string | XBRL taxonomy namespace URI |
| `facts` | object | Mapping of business metrics to XBRL concepts |

### 3.7 `provenance` (OPTIONAL)

Content provenance and signing metadata. Inspired by C2PA.

#### 3.7.1 `provenance.c2pa`

| Field | Type | Description |
|---|---|---|
| `assertions` | object | C2PA assertion mappings |
| `assertions.brand_policy_hash` | object | SHA-256 hash of the .m3m3tic file |
| `assertions.ai_generation_disclosure` | object | Whether AI-generated content disclosure is required |

### 3.8 `enforcement` (OPTIONAL)

Validation and enforcement configuration.

| Field | Type | Description |
|---|---|---|
| `fail_exit_code` | integer | Process exit code on validation failure (default: 5) |
| `severity_levels` | object | Custom severity level definitions |
| `policy_packs` | array[string] | OPA/Rego policy packs to apply |

## 4. Validation

### 4.1 Structural Validation

Files are structurally validated against the JSON Schema at `schemas/v0.1.0/m3m3tic.schema.json`. This checks types, required fields, enum values, and format constraints.

### 4.2 Compliance Validation

Files are compliance-validated using OPA/Rego policies in the `policies/` directory. This checks business logic: prohibited terms appearing in examples, missing disclaimers for regulated industries, jurisdiction-specific requirements.

### 4.3 Signing

Validated files MAY be signed by an authorized tool. A signed file includes a `_credential` block containing:
- A SHA-256 hash of the canonical file content (excluding the `_credential` block)
- A digital signature from the validating tool
- The X.509 certificate chain of the signer

Signed files can be verified offline using the signer's published public key.

## 5. Extensibility

### 5.1 Custom Sections

Tools MAY add custom top-level sections prefixed with `x_` (e.g., `x_bonfire`, `x_agency_internal`). Custom sections MUST NOT conflict with standard section names. Validators SHOULD ignore unrecognized `x_` sections.

### 5.2 Platform Extensions

New platform configurations can be added under `platforms.*` without a spec change. The spec defines the structure for `platforms.meta`. Other platforms (Google Ads, TikTok, LinkedIn) follow the same pattern.

## 6. Security Considerations

- `.m3m3tic` files MAY contain business-sensitive information (account IDs, distributor IDs)
- Files SHOULD NOT contain secrets (API keys, access tokens, passwords)
- Signed files provide tamper detection but not confidentiality
- Tools SHOULD validate file integrity before applying configuration
