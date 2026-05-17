# Architecture Overview

## The Two Files

| File | Purpose | Owned By |
|---|---|---|
| `.m3m3tic` | Brand + relationships + policy declarations | Brand owner |
| `.cr3st4n1` | Actor identity + credential | Actor (issued by Bonfire) |

## The Five Evaluation Layers

```
┌─────────────────────────────────────────────────────────────┐
│  5. JURISDICTION LAYER (external .rego policy packs)        │
│     OPA/Rego files. Pluggable. Versioned per regulator.     │
│     Self-select via audience geo. Never in base schema.     │
├─────────────────────────────────────────────────────────────┤
│  4. CONTENT LAYER (runtime object, not persisted)           │
│     The thing being evaluated. Media type, claims,          │
│     disclosures, evidence, audience targeting.              │
├─────────────────────────────────────────────────────────────┤
│  3. BRAND LAYER (.m3m3tic file)                             │
│     Voice, visual, terminology, platform config.            │
│     Also: relationships[], legal jurisdictions.             │
├─────────────────────────────────────────────────────────────┤
│  2. RELATIONSHIP LAYER (.m3m3tic relationships[])           │
│     Who delegated what to whom. Compensation, authority,    │
│     spend ceilings, approval gates, duration.               │
├─────────────────────────────────────────────────────────────┤
│  1. IDENTITY LAYER (.cr3st4n1 file)                         │
│     Who the actor IS. Verified, hardware-bound,             │
│     trust level 0-5. Pure identity, nothing else.           │
└─────────────────────────────────────────────────────────────┘
```

## The Evaluation Function

```
ALLOW/DENY = f(actor, relationship, brand, content, medium, claims, platform, jurisdiction[])
```

Nothing is evaluated in isolation. The evaluator receives the full context and runs all applicable policy packs.

## How Evaluation Works

1. Load actor's `.cr3st4n1` → verify Ed25519 signature + device binding
2. Load brand's `.m3m3tic` → find relationship matching actor_ref (SHA-256 hash match)
3. If no match → DENY ("actor not authorized for this brand")
4. If relationship.status != active → DENY ("relationship expired/terminated")
5. Construct evaluation input from all layers
6. Determine applicable jurisdictions from `content.audience.geos`
7. Resolve policy inheritance graph (`_jurisdiction-graph.yaml`)
8. Load all applicable policy packs (Tier 1 canonical + Tier 2 regional + Tier 3 overlay)
9. Run ALL applicable policies against full context
10. Collect results: any "block" = DENY, any "warn" = WARN, all pass = ALLOW

## Policy Pack Architecture

```
policies/
├── _interface.rego              # shared helpers
├── _jurisdiction-graph.yaml     # inheritance model
├── us/...                       # Tier 1: canonical
├── eu/...
├── gb/...
├── ru/...
├── cn/...
├── jp/...
├── kr/...
├── br/...
├── in/...
├── ng/...
├── ae/...                       # Tier 3: country overlays
├── sa/...
├── sg/...
├── tr/...
├── mx/...
├── mlm/...                      # Industry-specific
└── brand/...                    # Brand-level (always runs)
```

Every policy pack:
- Self-selects via `applicable` rule (checks audience geos)
- Returns `deny[result]` with: rule, severity, message, jurisdiction, remediation
- Uses the same input schema (full evaluation context)
- Can only RESTRICT, never expand permissions

## Key Design Decisions

- No jurisdiction logic in base schema (ADR-005)
- Two file types only (ADR-004)
- Relationships inside .m3m3tic (ADR-006)
- Composition emerges from evaluation (ADR-007)
- AI agents chain to human operators (ADR-008)
- Jurisdiction inheritance graph (ADR-009)

## On-Chain Settlement (Optional)

For affiliate/commission relationships, the M3M3TIC Protocol on Base L2 handles:
- EIP-712 signed referral events
- 3-way split: protocol (10%) + affiliate (X%) + vendor (remainder)
- USDC settlement
- Soulbound NFT for tier tracking
- Merkle-root payout audit trail
