# Policy Pack Authoring Guide

How to write OPA/Rego policy packs for the .m3m3tic ecosystem.

## Structure

Every policy pack is a single `.rego` file in the `policies/` directory, organized by jurisdiction:

```
policies/{jurisdiction_code}/{regulation-name}.rego
```

Examples:
- `policies/us/ftc-endorsement-2024.1.rego`
- `policies/jp/stealth-marketing-2023.rego`
- `policies/brand/terminology.rego`

## Template

```rego
# {Regulation Full Name}
#
# Regulation: {Official law/rule name}
# Version: {Year.revision}
# Effective: {Date}
# Source: {URL to official text}
# Maintainer: {who maintains this pack}

package m3m3tic.policy.{jurisdiction}.{regulation_name}

import future.keywords.in
import future.keywords.if

# ═══════════════════════════════════════════════════════════
# APPLICABILITY — when does this policy fire?
# ═══════════════════════════════════════════════════════════

applicable if {
    "{JURISDICTION_CODE}" in input.content.audience.geos
}

# ═══════════════════════════════════════════════════════════
# RULES
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    # ... your condition ...
    result := {
        "rule": "{jurisdiction}-{regulation}-{specific-rule-id}",
        "severity": "block",    # block | warn
        "message": "Human-readable explanation of the violation",
        "jurisdiction": "{JURISDICTION_CODE}",
        "remediation": "What the actor should do to fix this"
    }
}
```

## The Input Schema

Every policy receives the same input object:

```json
{
  "actor": {
    "identity": { "type": "human", "display_name": "...", "email": "..." },
    "trust": { "level": 3 },
    "device": { "binding_level": "fingerprinted" }
  },
  "relationship": {
    "type": "affiliate",
    "compensation": { "model": "commission", "rate": 0.15 },
    "authority": { "brand_voice": false, "spend": false, "platforms": [...] }
  },
  "brand": {
    "entity": { "brand_name": "...", "jurisdiction": "US" },
    "voice": { "prohibited_terms": [...] },
    "terminology": { "prohibited_terms": [...] },
    "platform_config": { "meta": {...} }
  },
  "content": {
    "medium": { "platform": "meta", "placement": "instagram_feed", "format": "SINGLE_IMAGE", "mode": "static" },
    "creative": { "primary_text": "...", "headline": "...", "cta": "SHOP_NOW" },
    "claims": [{ "type": "factual", "category": "performance", "text": "...", "evidence": [...] }],
    "disclosures_attached": [{ "type": "branded_content", "method": "platform_toggle" }],
    "provenance": { "ai_generated": false, "ai_assisted": true },
    "audience": { "geos": ["US", "GB"], "age_min": 18 },
    "spend_amount": 5000,
    "live_metadata": null
  },
  "legal": {
    "jurisdictions": [{ "id": "US", "policy_packs": ["ftc-endorsement-2024.1"] }]
  }
}
```

## Rules for Writing Policies

### DO:
1. Always gate with `applicable` — never assume your jurisdiction applies
2. Return structured results with ALL fields (rule, severity, message, jurisdiction, remediation)
3. Make remediation actionable ("Add #ad as first word" not "Fix disclosure")
4. Use the shared `_interface.rego` helpers where possible
5. Version your policy: include regulation version in filename
6. Include header comments with law citation, effective date, source URL
7. Test against both compliant and non-compliant content

### DON'T:
1. Never hardcode brand-specific logic (that belongs in brand.terminology)
2. Never access fields that don't exist without default handling (`object.get`)
3. Never return severity "block" for guidance/recommendation (use "warn")
4. Never assume English content (support multi-language checks)
5. Never reference other policy packs directly (each is independent)

## Severity Levels

| Level | Meaning | Effect |
|---|---|---|
| `block` | Hard regulatory violation. Content CANNOT publish. | DENY |
| `warn` | Best practice / guidance-level issue. Content CAN publish with flag. | WARN |

## Testing Your Policy

```bash
# Validate Rego syntax
opa check policies/your-jurisdiction/your-policy.rego

# Run against test input
opa eval -i test-input.json -d policies/ "data.m3m3tic.policy.your_jurisdiction.your_policy.deny"

# Run full evaluation (all policies)
m3m3tic evaluate --brand brand.m3m3tic --actor actor.cr3st4n1 --content content.yaml --geos YOUR_GEO
```

## Contributing a New Jurisdiction

1. Create directory: `policies/{iso_code}/`
2. Write your .rego file following the template above
3. Add entry to `_jurisdiction-graph.yaml` (specify parent if inheriting)
4. Add test fixtures (1 compliant, 1 non-compliant content object)
5. Submit PR with: law citation, effective date, penalty information

## Inheritance

If your jurisdiction inherits from another (e.g., New Zealand inherits from Australia):

```yaml
# In _jurisdiction-graph.yaml
NZ:
  inherits: ["AU"]
  overlay: "nz/privacy-act-2020.rego"
```

Your policy only needs to cover the DELTA — what's different from the parent. The evaluator loads parent packs automatically.
