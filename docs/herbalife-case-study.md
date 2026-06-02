# Case Study: Herbalife Nutrition

## The Problem

Herbalife has 1.9M+ distributors in 90+ countries. Each distributor creates social media content independently. The compliance challenge:

- **Income claims**: FTC settlement (2016) prohibits unsupported earnings representations. Only 21% of distributors earn commissions in a typical month. Most earn <$200/mo.
- **Health claims**: FDA DSHEA restricts supplement claims. No "cure/treat/prevent" language allowed.
- **International variation**: China bans multi-level structure entirely (single-level only). Japan has 20-day cooling-off for MLM. Korea requires "광고" (not #ad). Brazil requires Portuguese. Each of 90+ countries has different rules.
- **Scale**: 1.9M distributors × daily social media posts × 90+ jurisdictions = billions of compliance decisions annually that currently rely on training PDFs nobody reads.

## The Solution

A single `herbalife.m3m3tic` file that:
1. Defines what the brand IS (voice, visual, products)
2. Grants authority to each distributor via relationships[] (commission model, no spend, no brand voice)
3. Declares 26 operating jurisdictions with specific policy packs
4. Includes income claim substantiation requirements with actual IDS data
5. Provides per-platform disclosure renderings (Instagram toggle, YouTube checkbox, blog block)

Each distributor gets a `.cr3st4n1` credential:
- Verified via HelloSign (distributor agreement signed)
- Verified via Circle.so (active membership)
- Hardware-bound to their device
- Trust level 3 (dual-gate)

## Evaluation at Content Creation

When a distributor creates a post in Bonfire Terminal:
1. Their .cr3st4n1 is verified (offline, <1ms)
2. Matched to their relationship in herbalife.m3m3tic
3. Content evaluated against all applicable jurisdiction policies
4. DENY = post blocked with specific remediation guidance
5. ALLOW = post published with auto-attached disclosures

## What Gets Blocked (Examples)

| Content | Violation | Jurisdiction | Remediation |
|---|---|---|---|
| "Make $5000/month!" | Always-prohibited income pattern | ALL | Remove income claim entirely |
| "Cure your diabetes" | Disease claim for supplement | US, AU, GB | Remove; use structure/function claim only |
| "Best nutrition brand" | Absolute term banned | CN | Remove superlative for China-targeted content |
| Content without "광고" label | Wrong disclosure format | KR | Use "광고" (only accepted term in Korea) |
| Recruitment emphasis | Pyramid scheme indicator | EU, FR, AU | Refocus on product benefits |
| Push notification at 10PM KST | Night-time ban violation | KR | Reschedule to before 9PM |

## What Gets Allowed (Examples)

| Content | Why It Passes |
|---|---|
| "Start your morning with 24g of protein" | Product fact from label; no health claim |
| "Come visit us 7am-3pm!" | Location/hours; no claims |
| "12 delicious flavors available" | Product info; factual |
| Product photo with #ad disclosure | Proper disclosure + no claims |

## Trial Metrics (Targets)

| Metric | Target |
|---|---|
| Compliance rate at publish | >95% |
| False positive (wrongly blocked) | <5% |
| Evaluation latency | <100ms |
| Distributor onboarding time | <10 minutes |
| Policy coverage | All 26 declared jurisdictions |

## Why Herbalife First

Herbalife is the perfect first customer because:
1. **Highest compliance risk**: MLM + health supplements + income claims = maximum regulatory surface
2. **International**: 90+ countries means the jurisdiction system gets stress-tested
3. **Scale**: 1.9M distributors proves the credential issuance flow works
4. **FTC precedent**: $200M settlement means compliance isn't optional — it's existential
5. **If .m3m3tic can handle Herbalife, it can handle any brand**
