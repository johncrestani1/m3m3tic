# Evaluation Flow

Step-by-step walkthrough of how content is evaluated against the .m3m3tic stack.

## Sequence Diagram

```
Actor creates content
       │
       ▼
┌──────────────┐     ┌──────────────┐
│ Load .cr3st4n1│────▶│ Verify Ed25519│
│ (actor file)  │     │ + device bind │
└──────────────┘     └──────┬───────┘
                            │ VALID?
                            ▼
                     ┌──────────────┐
                     │ Load .m3m3tic │
                     │ (brand file)  │
                     └──────┬───────┘
                            │
                            ▼
                     ┌──────────────────────┐
                     │ Match actor_ref       │
                     │ (SHA-256 hash match)  │
                     └──────┬───────────────┘
                            │ FOUND?
                            ▼
                     ┌──────────────────────┐
                     │ Extract relationship  │
                     │ (type, authority,     │
                     │  compensation)        │
                     └──────┬───────────────┘
                            │
                            ▼
                     ┌──────────────────────┐
                     │ Build evaluation      │
                     │ context (all layers)  │
                     └──────┬───────────────┘
                            │
                            ▼
                     ┌──────────────────────┐
                     │ Resolve jurisdictions │
                     │ (audience.geos ∩      │
                     │  legal.jurisdictions) │
                     └──────┬───────────────┘
                            │
                            ▼
                     ┌──────────────────────┐
                     │ Load policy packs     │
                     │ (inheritance graph)   │
                     └──────┬───────────────┘
                            │
                            ▼
                     ┌──────────────────────┐
                     │ Run ALL applicable    │
                     │ policies in parallel  │
                     └──────┬───────────────┘
                            │
                            ▼
                     ┌──────────────────────┐
                     │ Collect results       │
                     │ block? → DENY         │
                     │ warn?  → WARN         │
                     │ none?  → ALLOW        │
                     └──────────────────────┘
```

## Example: Herbalife Distributor Posts on Instagram

**Input:**
- Actor: Maria Gonzalez (.cr3st4n1, trust level 3, dual-gate verified)
- Brand: Herbalife Nutrition (.m3m3tic, 26 operating jurisdictions)
- Content: "Start your morning right with a smoothie packed with 24g of protein. #HerbalifeNutrition"
- Platform: Instagram feed, static image
- Audience: US + GB
- Claims: factual ("24g of protein"), category: product_spec
- Evidence: product label (Formula 1 Vanilla nutrition facts)

**Evaluation Steps:**

1. Verify Maria's .cr3st4n1 → Ed25519 valid, device matches, trust=3 ✓
2. Load Herbalife .m3m3tic → find relationship where actor_ref matches Maria's credential hash
3. Found: type=franchisee, compensation=commission, brand_voice=false, spend=false ✓
4. Build context: actor + relationship + brand + content
5. Audience geos ["US", "GB"] ∩ legal.jurisdictions → loads US + GB packs
6. Applicable policies:
   - us/ftc-endorsement-2024.1.rego (compensated actor)
   - gb/asa-cap-code-ed12.rego (compensated actor)
   - mlm/income-claims-international.rego (MLM entity)
   - brand/terminology.rego (always)
   - brand/delegation-scope.rego (always)
7. Results:
   - FTC: disclosure required (Maria is compensated affiliate) → checks disclosures_attached → WARN "No disclosure attached; add #ad or branded content toggle"
   - ASA: same → WARN
   - MLM income: no income claim in text → PASS
   - Terminology: no prohibited terms → PASS
   - Delegation: organic_post.create is in granted operations → PASS
8. Final: WARN (content CAN publish, but should add disclosure)

**If Maria instead posted: "Make $5000/month with Herbalife!"**

7. Results:
   - MLM income: contains "Make $X/month" pattern → BLOCK
   - FTC: income claim without typicality statement → BLOCK
   - ASA: specific figure without average → BLOCK
   - Terminology: no prohibited term exact match → PASS
8. Final: DENY (3 violations, content cannot publish)

## Timing

| Step | Expected Duration |
|---|---|
| .cr3st4n1 verification | <1ms (Ed25519 + hash compare) |
| .m3m3tic parse + relationship match | ~5ms |
| Context construction | ~2ms |
| Jurisdiction resolution | ~1ms |
| Policy pack loading | ~10ms (cached after first load) |
| Policy evaluation (all packs) | ~30-50ms |
| **Total** | **<100ms** |
