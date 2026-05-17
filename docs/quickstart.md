# Quickstart: Create Your First .m3m3tic File

A 5-minute guide to creating a brand compliance file.

## What You Need
- A text editor (VS Code, Vim, anything that writes YAML)
- Your brand guidelines (colors, voice, terminology)
- Knowledge of which platforms you advertise on

## Step 1: Start with the minimum

```yaml
m3m3tic:
  version: "0.2.0"
```

That's a valid .m3m3tic file. Everything else is optional.

## Step 2: Add your entity

```yaml
entity:
  legal_name: "Your Company LLC"
  brand_name: "YourBrand"
  domain: "yourbrand.com"
  jurisdiction: "US"
  operating_jurisdictions: ["US", "GB"]
```

## Step 3: Define your brand voice

```yaml
brand:
  voice:
    primary_tone: "professional"
    avoided_tones: ["aggressive", "salesy"]
    good_examples:
      - "We help teams ship faster."
    bad_examples:
      - "BUY NOW OR MISS OUT FOREVER!!!"
  terminology:
    prohibited_terms:
      - { term: "guaranteed", reason: "no outcome guarantees" }
```

## Step 4: Add platform configuration

```yaml
  platform_config:
    meta:
      campaign:
        objectives_allowed: [OUTCOME_LEADS, OUTCOME_TRAFFIC]
      creative:
        cta_allowed: [LEARN_MORE, SIGN_UP]
```

## Step 5: Add a relationship (who can act for your brand)

```yaml
relationships:
  - actor_ref: "sha256:..."  # hash of their .cr3st4n1 credential
    actor_name: "Agency Name"
    type: "agency"
    authority:
      brand_voice: true
      spend: true
      spend_ceiling_monthly: 50000
    status: "active"
```

## Step 6: Declare your jurisdictions

```yaml
legal:
  jurisdictions:
    - id: "US"
      policy_packs: ["ftc-endorsement-2024.1"]
    - id: "GB"
      policy_packs: ["asa-cap-code-ed12"]
```

## Step 7: Validate

```bash
ajv validate -s schemas/v0.2.0/m3m3tic.schema.json -d your-brand.m3m3tic
```

## Step 8: Evaluate content

```bash
m3m3tic evaluate --brand your-brand.m3m3tic --actor actor.cr3st4n1 --content post.yaml --geos US,GB
```

## What's Next?
- Add disclosure renderings for each platform
- Add more relationships (affiliates, influencers)
- Write custom policy packs for your industry
- Connect to Bonfire Terminal for automated evaluation
