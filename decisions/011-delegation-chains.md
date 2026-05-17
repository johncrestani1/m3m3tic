# ADR-011: Delegation Chains

## Status
Accepted

## Context
An agency (Salvo Media) may subcontract to freelancers. A brand gives authority to an agency; the agency needs to delegate some of that authority downstream. Without delegation support, every sub-actor needs a direct relationship entry in the brand's .m3m3tic file — impractical at scale.

Options considered:
(a) Flat only — every actor listed directly in relationships[]
(b) Unlimited delegation depth
(c) Controlled delegation with depth limit and scope restriction

## Decision
Option (c). Relationships can include:
- `authority.can_delegate: true|false` — whether this actor can delegate to sub-actors
- `authority.delegation_depth: N` — how many levels deep delegation can go (default: 0 = no delegation)
- `authority.delegatable_operations: [...]` — which operations can be delegated (subset of granted)

At evaluation time, the evaluator walks the delegation chain: brand → primary actor → delegated actor. Each link can only RESTRICT scope, never expand it. The delegated actor's effective authority = intersection of all links in the chain.

Delegation is tracked off-chain (in Bonfire Terminal's internal state). The .m3m3tic file declares the POLICY; the daemon enforces it at runtime.

## Consequences
- Agencies can onboard subcontractors without brand owner updating .m3m3tic
- Delegation depth limits prevent unbounded chains (agency → sub-agency → freelancer → ??? )
- Each delegation link is logged for audit
- Revocation cascades: if primary actor is terminated, all delegations under them are automatically revoked
- Delegation does NOT create a new .m3m3tic entry — it's an operational mechanism, not a spec artifact
