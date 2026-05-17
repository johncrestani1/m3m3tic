# .m3m3tic Taxonomy Rosetta Stone

**Purpose**: 1:1:1:1:1 field mapping between .m3m3tic, Russia erid/ORD, Meta Marketing API, Google Ads API, IAB OpenRTB/AdCOM, TikTok Business API, and China GB 45438.

**Why this matters**: If .m3m3tic maps cleanly to ALL of these, it becomes the universal compliance manifest that satisfies every system simultaneously. One file → all platforms → all jurisdictions.

---

## Source Schemas

| System | Format | Schema Location |
|---|---|---|
| Russia ORD (VK) | OpenAPI/Swagger YAML | https://ord.vk.com/help/api/swagger/swagger.yaml |
| Russia ORD (MediaScout) | Python SDK | https://pypi.org/project/ord-mediascout-client/ |
| Meta Marketing API | JSON (enum_types.json) | https://github.com/facebook/facebook-business-sdk-codegen/blob/main/api_specs/specs/enum_types.json |
| Google Ads API | Protobuf (.proto) | https://github.com/googleapis/googleapis/tree/master/google/ads/googleads |
| IAB OpenRTB 2.6 | JSON Schema | https://github.com/klaussilveira/openrtb-json-schema |
| IAB Taxonomies | TSV | https://github.com/InteractiveAdvertisingBureau/Taxonomies |
| IAB AdCOM 1.0 | Spec | https://github.com/InteractiveAdvertisingBureau/AdCOM |
| TikTok Business API | JSON (REST) | https://github.com/tiktok/tiktok-business-api-sdk |
| China GB 45438-2025 | National Standard | CAC publication (metadata schema for AI content) |

---

## 1. ENTITY / ADVERTISER IDENTITY

The "who is advertising" layer. Every system needs to know the legal entity behind an ad.

| .m3m3tic Field | Russia ORD | Meta API | Google Ads | IAB OpenRTB | China | Description |
|---|---|---|---|---|---|---|
| `entity.legal_name` | `advertiser.name` | Business Manager name | `customer.descriptive_name` | N/A (buyer-side) | Real-name registration | Legal entity name |
| `entity.brand_name` | N/A | Page.name | `campaign.name` (informal) | `seat` (buyer seat) | N/A | Public brand name |
| `entity.domain` | `platform.domain` | Page.website | `customer.website_url` | `site.domain` / `app.bundle` | ICP domain | Primary website |
| `entity.jurisdiction` | Implied (RU) | Country of ad account | `customer.time_zone` (proxy) | `device.geo.country` | CN (mandatory) | Legal jurisdiction |
| `entity.industry` | `classifier.kktu_code` | Page.category | `campaign.advertising_channel_type` | `site.cat` (IAB taxonomy) | Business license category | Industry classification |
| `entity.vertical` | `classifier.kktu_code` | N/A | vertical topics | `site.cattax` + `site.cat` | N/A | Business vertical |
| `entity.category.id` | KKTU code | Page.category_list[].id | N/A | IAB Content Taxonomy ID | N/A | Platform category ID |
| N/A (new field needed) | `advertiser.inn` | N/A | N/A | N/A | Unified Social Credit Code | Tax/registration ID |
| N/A (new field needed) | `advertiser.ogrn` | Business Manager ID | Customer ID | N/A | Business License # | Registration number |
| N/A (new field needed) | `advertiser.legal_form` | N/A | N/A | N/A | N/A | Legal entity type (LLC, Corp, etc.) |

### Proposed .m3m3tic v0.2.0 Addition

```yaml
entity:
  legal_name: "Ring Concierge LLC"
  brand_name: "Ring Concierge"
  domain: "ringconcierge.com"
  jurisdiction: "US"
  registrations:
    us_ein: "XX-XXXXXXX"           # US tax ID (maps to Russia INN equivalent)
    ru_inn: null                    # Russian taxpayer ID (if operating in RU)
    cn_uscc: null                   # Chinese Unified Social Credit Code
    eu_vat: null                    # EU VAT number
  industry:
    iab_content_taxonomy: "552"     # IAB Content Taxonomy v3.0 ID (Style & Fashion)
    iab_ad_product_taxonomy: "1058" # IAB Ad Product Taxonomy 2.0 (Clothing & Accessories)
    kktu_code: null                 # Russia KKTU classifier (if operating in RU)
    meta_category_id: "187133811313032"  # Meta Page Category ID (Jewelry/Watches)
```

---

## 2. CAMPAIGN OBJECTIVE / PURPOSE

The "what are we trying to achieve" layer.

| .m3m3tic Field | Russia ORD | Meta API | Google Ads | TikTok | IAB OpenRTB | Description |
|---|---|---|---|---|---|---|
| `platforms.meta.campaign.objective_allowed[]` | N/A (not tracked) | `Campaign.objective` | `AdvertisingChannelType` | `objective_type` | N/A (exchange-level) | Campaign goal |

### Cross-Platform Objective Mapping

| Business Goal | Meta (ODAX) | Google Ads | TikTok | .m3m3tic enum |
|---|---|---|---|---|
| Brand awareness | `OUTCOME_AWARENESS` | `DISPLAY` / `VIDEO` | `REACH` | `awareness` |
| Website traffic | `OUTCOME_TRAFFIC` | `SEARCH` / `DISPLAY` | `TRAFFIC` | `traffic` |
| Engagement | `OUTCOME_ENGAGEMENT` | `DISPLAY` | `ENGAGEMENT` / `VIDEO_VIEWS` | `engagement` |
| Lead generation | `OUTCOME_LEADS` | `SEARCH` / `PERFORMANCE_MAX` | `LEAD_GENERATION` | `leads` |
| Sales/conversions | `OUTCOME_SALES` | `SHOPPING` / `PERFORMANCE_MAX` | `WEB_CONVERSIONS` / `PRODUCT_SALES` | `sales` |
| App installs | `OUTCOME_APP_PROMOTION` | `MULTI_CHANNEL` | `APP_PROMOTION` | `app_promotion` |

### Proposed .m3m3tic v0.2.0

```yaml
platforms:
  meta:
    campaign:
      objective_allowed:
        - OUTCOME_SALES          # native Meta enum
        - OUTCOME_LEADS
  google_ads:
    campaign:
      channel_type_allowed:
        - SEARCH
        - SHOPPING
        - PERFORMANCE_MAX
  tiktok:
    campaign:
      objective_allowed:
        - WEB_CONVERSIONS
        - PRODUCT_SALES

  # Universal (cross-platform) objective constraint
  objectives_allowed:            # .m3m3tic universal enum
    - sales
    - leads
    - traffic
```

---

## 3. AD CREATIVE TYPE / FORMAT

| .m3m3tic Field | Russia ORD | Meta API | Google Ads | TikTok | IAB AdCOM | Description |
|---|---|---|---|---|---|---|
| `platforms.*.creative.format` | Creative type (text/banner/video/audio) | `ad_format_type` | `AdType` | `creative_type` | `Ad.display` / `Ad.video` / `Ad.audio` | Media format |

### Cross-Platform Format Mapping

| Format | Meta | Google Ads | TikTok | Russia ORD | IAB AdCOM | .m3m3tic enum |
|---|---|---|---|---|---|---|
| Static image | `SINGLE_IMAGE` | `IMAGE_AD` | image | Banner | `display` | `image` |
| Video | `SINGLE_VIDEO` | `VIDEO_BUMPER_AD` / `VIDEO_TRUEVIEW_IN_STREAM_AD` | video | Video | `video` | `video` |
| Carousel | `CAROUSEL_IMAGE` | `DEMAND_GEN_CAROUSEL_AD` | carousel | Banner (multi) | N/A | `carousel` |
| Collection | `COLLECTION` | N/A | N/A | N/A | N/A | `collection` |
| Responsive search | N/A | `RESPONSIVE_SEARCH_AD` | N/A | Text | N/A | `responsive_text` |
| Audio | N/A | `YOUTUBE_AUDIO_AD` | N/A | Audio | `audio` | `audio` |
| Native | N/A | N/A | N/A | N/A | `native` | `native` |

---

## 4. CALL TO ACTION

| .m3m3tic Field | Meta API | Google Ads | TikTok | Description |
|---|---|---|---|---|
| `platforms.meta.creative.cta_allowed[]` | `call_to_action_type` | `CallToActionType` | (in creative) | Allowed CTA buttons |

### Cross-Platform CTA Mapping

| Intent | Meta | Google Ads | .m3m3tic universal |
|---|---|---|---|
| Learn more | `LEARN_MORE` | `LEARN_MORE` | `learn_more` |
| Shop | `SHOP_NOW` | `SHOP_NOW` | `shop_now` |
| Sign up | `SIGN_UP` | `SIGN_UP` | `sign_up` |
| Book | `BOOK_NOW` | `BOOK_NOW` | `book_now` |
| Contact | `CONTACT_US` | `CONTACT_US` | `contact` |
| Download | `DOWNLOAD` | `DOWNLOAD` | `download` |
| Apply | `APPLY_NOW` | `APPLY_NOW` | `apply` |
| Subscribe | `SUBSCRIBE` | `SUBSCRIBE` | `subscribe` |
| Get quote | `GET_A_QUOTE` | `GET_QUOTE` | `get_quote` |
| Donate | `DONATE_NOW` | `DONATE_NOW` | `donate` |
| Watch | `WATCH_VIDEO` | `WATCH_NOW` | `watch` |
| Order | `ORDER_NOW` | `ORDER_NOW` | `order_now` |
| Call | `CALL_NOW` | N/A | `call` |
| Message | `WHATSAPP_MESSAGE` / `MESSAGE_PAGE` | N/A | `message` |
| Get directions | `GET_DIRECTIONS` | N/A | `get_directions` |
| Play | `PLAY_GAME` | `PLAY_NOW` | `play` |

**Full Meta CTA enum** (100+ values): see `facebook-business-sdk-codegen/api_specs/specs/enum_types.json`

---

## 5. SPECIAL AD CATEGORIES / RESTRICTIONS

| .m3m3tic Field | Meta API | Google Ads | Russia | China | Description |
|---|---|---|---|---|---|
| `platforms.meta.campaign.special_ad_categories[]` | `Campaign.special_ad_categories` | Policy-based (not field) | Category bans (38-FZ) | Category bans (Advertising Law) | Restricted categories |

### Cross-Platform Restricted Category Mapping

| Category | Meta enum | Google policy | Russia 38-FZ | China Ad Law | IAB Ad Product | .m3m3tic |
|---|---|---|---|---|---|---|
| Housing | `HOUSING` | Housing policy | N/A | N/A | N/A | `restricted.housing` |
| Employment | `EMPLOYMENT` | Employment policy | N/A | N/A | 1295 | `restricted.employment` |
| Credit/Finance | `CREDIT` | Financial services policy | Disclaimer required | Disclaimer required | 1335 | `restricted.credit` |
| Politics | `ISSUES_ELECTIONS_POLITICS` | Political content policy | Foreign agent ban | Banned | N/A | `restricted.politics` |
| Alcohol | N/A (country-level) | Alcohol policy | Restricted (time/place) | Banned (some provinces) | 1002 | `restricted.alcohol` |
| Gambling | N/A (country-level) | Gambling policy | Licensed only | Banned | 1361 | `restricted.gambling` |
| Cannabis | N/A (banned most countries) | Cannabis policy | Banned | Banned | 1049 | `restricted.cannabis` |
| Pharma/Health | N/A (review required) | Healthcare policy | Disclaimer required | Pre-approval required | 1378 | `restricted.health` |
| Crypto | N/A (FCA requires auth) | Crypto policy | Restricted | Restricted | 1448 | `restricted.crypto` |

---

## 6. TARGETING / AUDIENCE

| .m3m3tic Field | Meta API | Google Ads | IAB OpenRTB | Russia ORD | Description |
|---|---|---|---|---|---|
| `platforms.meta.targeting.geo` | `targeting_spec.geo_locations` | `campaign_criterion.location` | `device.geo` | `region` (required) | Geographic targeting |
| `platforms.meta.targeting.age_min` | `targeting_spec.age_min` | `ad_group_criterion.age_range` | `user.yob` (birth year) | N/A | Age floor |
| `platforms.meta.targeting.age_max` | `targeting_spec.age_max` | `ad_group_criterion.age_range` | N/A | N/A | Age ceiling |
| N/A | `targeting_spec.flexible_spec.interests[]` | `ad_group_criterion.user_interest` | `user.data.segment[]` | N/A | Interest targeting |
| N/A | `targeting_spec.custom_audiences[]` | `user_list` resource | N/A | N/A | Custom audiences |

### IAB Audience Taxonomy Integration

```yaml
platforms:
  universal:
    targeting:
      iab_audience_segments:        # IAB Audience Taxonomy 1.1 IDs
        - "600"                      # Purchase Intent > Automotive
        - "601"                      # Purchase Intent > Beauty
      excluded_segments:
        - "sensitive.health"         # GDPR special category
        - "sensitive.politics"
```

---

## 7. COMPLIANCE / DISCLOSURE TOKEN

The critical mapping — where .m3m3tic connects to regulatory compliance systems.

| .m3m3tic Field | Russia erid | EU DSA | China GB 45438 | Meta API | IAB TCF | Description |
|---|---|---|---|---|---|---|
| `disclosures.renderings.*.erid_marking.token` | `erid` (base58 protobuf) | N/A | N/A | N/A | N/A | Russian ad registry token |
| `disclosures.renderings.*.dsa_transparency` | N/A | Ad repository entry | N/A | `branded_content_sponsor_page_id` | N/A | EU ad transparency |
| `provenance.c2pa.assertions.ai_generation_disclosure` | N/A | AI Act Art. 50 label | `provider_code` + `content_id` + `timestamp` | N/A | N/A | AI content provenance |
| `disclosures.renderings.instagram.ftc_endorsement` | N/A | N/A | N/A | `branded_content_sponsor_page_id` | N/A | FTC endorsement disclosure |
| N/A | N/A | N/A | N/A | N/A | TCF `tc_string` | GDPR consent signal |

### Russia ORD Fields → .m3m3tic Mapping (Complete)

| Russia ORD Field | .m3m3tic v0.2.0 Field | Notes |
|---|---|---|
| `advertiser.inn` | `entity.registrations.ru_inn` | Tax ID |
| `advertiser.ogrn` | `entity.registrations.ru_ogrn` | Registration # |
| `advertiser.name` | `entity.legal_name` | Legal entity |
| `advertiser.legal_form` | `entity.legal_form` | LLC, JSC, etc. |
| `classifier.kktu_code` | `entity.industry.kktu_code` | Product category |
| `creative.type` | `platforms.yandex.creative.format` | Media type |
| `creative.media_content` | (external asset ref) | The ad itself |
| `creative.target_url` | `platforms.yandex.creative.landing_url` | Click destination |
| `creative.erid` | `compliance.erid.token` | The token |
| `contract.id` | `agency.engagement_ref` | Contract reference |
| `contract.parties[]` | `agency.provider` + `entity` | Chain participants |
| `contract.dates` | `agency.effective_date` + `duration` | Contract period |
| `statistics.impressions` | (reporting layer, not in .m3m3tic) | Monthly stats |
| `statistics.cost` | (reporting layer) | Spend data |
| `platform.domain` | `entity.domain` | Where ad shown |
| `region` | `platforms.yandex.targeting.geo` | Target region |

### China GB 45438 Fields → .m3m3tic Mapping

| GB 45438 Field | .m3m3tic v0.2.0 Field | Notes |
|---|---|---|
| `provider_code` | `provenance.generator.tool` + registry ID | Who generated the AI content |
| `content_id` | `provenance.content_hash` | Unique content identifier |
| `generation_timestamp` | `provenance.c2pa.assertions.generation_timestamp` | When AI created it |
| `content_type` | `platforms.*.creative.format` | Text/image/video/audio |
| Visible label ("AI生成") | `disclosures.renderings.wechat.ai_generated.text` | User-visible marker |
| Metadata watermark | `provenance.c2pa.assertions.brand_policy_hash` | Machine-readable marker |

### EU AI Act Article 50 → .m3m3tic Mapping

| AI Act Requirement | .m3m3tic v0.2.0 Field | Notes |
|---|---|---|
| Machine-readable label | `provenance.c2pa.assertions.ai_generation_disclosure.machine_readable: true` | Metadata in file |
| Detectable as AI-generated | `provenance.c2pa.assertions.brand_policy_hash.source` | Watermark hash |
| Human-visible disclosure | `disclosures.renderings.*.ai_generated.text` | Per-platform label |
| Provider identification | `provenance.generator.tool` + `provenance.generator.version` | Tool that created content |

---

## 8. CONSENT / PRIVACY

| .m3m3tic Field | IAB TCF v2.2 | Meta Consent Mode | Google Consent Mode v2 | Description |
|---|---|---|---|---|
| `platforms.meta.targeting.eu_consent_required` | Purpose 1-4 consent | `consent_mode` parameter | `ad_storage`, `analytics_storage` | Consent needed |
| `legal.regulations.gdpr.consent_required_for_tracking` | TCF `tc_string` | N/A | `ad_user_data`, `ad_personalization` | GDPR tracking consent |
| `legal.regulations.gdpr.special_categories_blocked` | TCF Purpose 3-4 | Special ad categories | Similar audiences restriction | Sensitive targeting ban |

### IAB TCF Purpose → .m3m3tic Mapping

| TCF Purpose ID | TCF Purpose Name | .m3m3tic equivalent |
|---|---|---|
| 1 | Store/access device info | `platforms.*.tracking.cookie_consent_required` |
| 2 | Select basic ads | `platforms.*.targeting.contextual_allowed` |
| 3 | Create ad profiles | `platforms.*.targeting.behavioral_allowed` |
| 4 | Select personalized ads | `platforms.*.targeting.personalized_allowed` |
| 7 | Measure ad performance | `platforms.*.tracking.conversion_tracking_allowed` |

---

## 9. REPORTING / FINANCIAL

| .m3m3tic Field | Russia ORD | Meta Insights | Google Ads Metrics | IAB | Description |
|---|---|---|---|---|---|
| `reporting.xbrl.facts.ad_spend` | `statistics.cost` | `spend` | `metrics.cost_micros` | `Bid.price` | Total spend |
| `reporting.xbrl.facts.protocol_fee_revenue` | N/A | N/A | N/A | N/A | M3M3TIC protocol fee |
| `spend_authority.monthly_ceiling_usd` | N/A | `campaign.budget_remaining` | `campaign_budget.amount_micros` | N/A | Budget limit |
| `sla.pricing.tiers[].fee` | `contract.cost` (acts) | N/A | N/A | N/A | Agency fee |

---

## 10. CONTRACT CHAIN (Russia-Specific, But Universal Opportunity)

Russia's ORD system uniquely requires the full contract chain — every entity involved in getting an ad published must be documented. No other system does this today, but EU DSA is moving in this direction.

| Russia ORD Contract Chain | .m3m3tic Equivalent | Status |
|---|---|---|
| `advertiser` (brand) | `entity` | Exists |
| `agency` (media buyer) | `agency.provider` | Exists in v0.2.0 |
| `platform` (where ad runs) | `platforms.*` | Exists |
| `contract.id` between parties | `agency.engagement_ref` | Exists in v0.2.0 |
| `act` (completion confirmation) | N/A | New field needed |
| `invoice` (financial record) | N/A | New field needed (or defer to on-chain) |

### Proposed Addition

```yaml
compliance:
  chain_of_custody:
    - role: "advertiser"
      entity_ref: "entity"
      registration: "{{entity.registrations}}"
    - role: "agency"
      entity_ref: "agency.provider"
      registration:
        ru_inn: "7707083893"
    - role: "platform"
      name: "Meta Platforms"
      registration:
        ru_inn: null  # blocked in RU
    - role: "ord_operator"
      name: "VK ORD"
      api_endpoint: "https://ord.vk.com/api/v1"

  erid:
    token: null                    # populated at publish time
    ord_operator: "vk"
    registered_at: null
    creative_hash: null            # SHA-256 of creative content
```

---

## 11. UNIVERSAL PRODUCT CATEGORY MAPPING

The IAB Taxonomies repo is the Rosetta Stone for product/content classification. Here's how all systems map:

| IAB Ad Product Taxonomy 2.0 ID | IAB Name | Russia KKTU (approximate) | Meta Category | Google Vertical |
|---|---|---|---|---|
| 1002 | Alcohol | Alcoholic beverages | Food & Beverage | Alcohol |
| 1049 | Cannabis | N/A (banned) | N/A (banned most) | Cannabis |
| 1058 | Clothing and Accessories | Textiles & clothing | Clothing (Brands) | Apparel |
| 1082 | Computer Software | Software | Software | Technology |
| 1097 | Consumer Electronics | Electronics | Electronics | Electronics |
| 1123 | Consumer Packaged Goods | FMCG | CPG brands | CPG |
| 1259 | Dating | Services | Dating Service | Dating |
| 1295 | Education and Careers | Educational services | Education | Education |
| 1335 | Finance and Insurance | Financial services | Financial Service | Finance |
| 1361 | Gambling | Gambling/lotteries | N/A (restricted) | Gambling |
| 1378 | Health and Medical | Medical/pharma | Health/Beauty | Healthcare |
| 1416 | Legal Services | Legal services | Legal | Legal |
| 1448 | Non-Fiat Currency | N/A | N/A (restricted) | Crypto |

### Proposed .m3m3tic Universal Category

```yaml
entity:
  category:
    iab_ad_product_id: "1058"       # IAB Ad Product Taxonomy 2.0
    iab_content_id: "552"           # IAB Content Taxonomy 3.0
    meta_category_id: "187133811313032"
    kktu_code: "14.1"              # Russia KKTU (textiles)
    google_vertical: "Apparel"
    restricted_category: null       # or: "HOUSING", "CREDIT", etc.
```

---

## 12. COMPLETE FIELD MAPPING TABLE (Summary)

| .m3m3tic v0.2.0 Field Path | RU ORD | Meta API | Google Ads | TikTok | IAB | CN GB45438 | EU AI Act |
|---|---|---|---|---|---|---|---|
| `entity.legal_name` | advertiser.name | BM.name | customer.descriptive_name | — | — | Real-name reg | — |
| `entity.registrations.ru_inn` | advertiser.inn | — | — | — | — | — | — |
| `entity.industry.iab_ad_product_id` | kktu_code | Page.category | vertical | — | Ad Product Tax | — | — |
| `platforms.meta.campaign.objective_allowed` | — | Campaign.objective | AdvertisingChannelType | objective_type | — | — | — |
| `platforms.meta.creative.format` | creative.type | ad_format_type | AdType | creative_type | Ad.display/video | content_type | — |
| `platforms.meta.creative.cta_allowed` | — | call_to_action_type | CallToActionType | — | — | — | — |
| `platforms.meta.campaign.special_ad_categories` | — | special_ad_categories | (policy) | — | — | (banned cats) | — |
| `platforms.meta.targeting.geo` | region | targeting_spec.geo_locations | campaign_criterion.location | geo | device.geo | — | — |
| `spend_authority.monthly_ceiling_usd` | — | campaign.budget_remaining | campaign_budget.amount_micros | budget | Bid.price | — | — |
| `compliance.erid.token` | erid | — | — | — | — | — | — |
| `compliance.chain_of_custody` | full contract chain | — | — | — | — | — | — |
| `provenance.c2pa.ai_disclosure` | — | — | — | — | — | provider_code+content_id | Art.50 metadata |
| `disclosures.renderings.*.ftc` | — | branded_content_sponsor_page_id | — | is_branded_content | — | — | — |
| `legal.regulations.gdpr.consent` | — | consent_mode | consent_mode_v2 | — | TCF tc_string | — | — |
| `reporting.xbrl.facts.ad_spend` | statistics.cost | insights.spend | metrics.cost_micros | — | — | — | — |

---

## 13. IMPLEMENTATION PRIORITY

### Phase 1 (v0.2.0 — ship now)
- Meta Marketing API full mapping (objectives, CTAs, formats, targeting, special categories)
- IAB taxonomy IDs as universal category identifiers
- FTC/ASA disclosure → `branded_content_sponsor_page_id` rendering
- Policy versioning per jurisdiction
- Restriction algebra (INTERSECT)

### Phase 2 (v0.3.0)
- Russia ORD integration (erid token generation via VK ORD API)
- China GB 45438 AI provenance metadata
- Google Ads protobuf mapping (full AdType + BiddingStrategy enums)
- TikTok Business API mapping
- IAB TCF consent signal passthrough

### Phase 3 (v0.4.0)
- Full contract chain (Russia ORD model applied globally)
- Cross-platform objective normalization (universal enum → platform-native)
- Real-time evidence refresh (claims auto-verification via platform APIs)
- ORD-style compliance registries for other jurisdictions (as they emerge)

---

## 14. THE INTEROPERABILITY ARGUMENT

When a brand publishes a `.m3m3tic` file, here's what each system gets:

| System | What it extracts from .m3m3tic | How it uses it |
|---|---|---|
| **Meta Ads Manager** | objectives, CTAs, creative specs, targeting, special_ad_categories | Pre-validates creative before submission |
| **Google Ads** | channel types, bidding constraints, targeting | Campaign configuration validation |
| **Russia ORD** | INN, KKTU, creative type, region, contract chain | Auto-populates erid registration form |
| **IAB OpenRTB** | content taxonomy IDs, ad product IDs | Bid request enrichment / brand safety |
| **China platforms** | Absolute terms blocklist, AI label requirements | Pre-publication content scanning |
| **EU DSA** | Advertiser identity, targeting criteria, AI disclosure | Ad repository transparency entry |
| **OPA/Rego validator** | ALL fields | Multi-jurisdiction compliance check |
| **Bonfire Terminal** | ALL fields | End-to-end enforcement pipeline |

**This is how you become infrastructure**: every system can extract what IT needs from the same file, without any system owning the format.
