# ADR-007: Emergent Restriction Composition (No Declared Algebra)

## Status
Accepted

## Context
v0.1.0 draft proposed explicit "restriction algebra" (INTERSECT for allowlists, UNION for blocklists, MIN for ceilings).

## Decision
Remove declared algebra. Composition emerges naturally from: all applicable policies run, any deny = blocked. No explicit algebra needed.

## Consequences
Simpler spec. No "composition mode" configuration. Adding a policy pack can only RESTRICT, never expand. The evaluation engine is just "run all, collect denials."
