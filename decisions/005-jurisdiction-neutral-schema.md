# ADR-005: No Jurisdiction Logic in Base Schema

## Status
Accepted

## Context
v0.1.0 hardcoded FTC/FDA sections. This makes the spec US-centric and requires schema changes for every new jurisdiction.

## Decision
Base schema is a pure ontology. All jurisdiction-specific rules live in external OPA/Rego policy packs. The schema declares WHICH jurisdictions apply; policies encode WHAT those jurisdictions require.

## Consequences
Adding Japan is adding a .rego file, not a schema change. Any country can use .m3m3tic without seeing US-specific fields.
