# ADR-009: Jurisdiction Policy Inheritance Graph

## Status
Accepted

## Context
195 countries. Writing 195 policy packs is impractical. Many countries inherit/defer to others (EEA to EU, GCC members, ASEAN, Commonwealth).

## Decision
Three-tier model: Tier 1 canonical (10 bespoke packs), Tier 2 regional inheritors (6 blocs), Tier 3 country overlays (delta from parent). Machine-readable _jurisdiction-graph.yaml.

## Consequences
Adding a new country = writing only the DELTA from its parent pack. Evaluator resolves inheritance chain at runtime.
