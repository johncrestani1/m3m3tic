# ADR-012: W3C Verifiable Credential Alignment Strategy

## Status
Proposed (not yet implemented)

## Context
The .cr3st4n1 credential is conceptually a Verifiable Credential (VC): a cryptographically signed attestation about a subject, issued by a trusted party, verifiable without contacting the issuer.

W3C VC Data Model v2.0 is the emerging standard for portable credentials. eIDAS 2.0 (EU, Dec 2026) mandates EUDI Wallets built on W3C VCs. Estonia is building AI Residency on similar foundations. Microsoft Entra Agent ID uses DIDs + VCs.

If .cr3st4n1 is NOT aligned with W3C VCs, we become an island. If it IS aligned, we get:
- Automatic recognition across 27 EU states (eIDAS 2.0)
- Interop with enterprise identity systems (Microsoft Entra)
- Interop with government identity (Estonia e-Residency)
- Academic/standards body legitimacy

## Decision
Align .cr3st4n1 with W3C VC Data Model v2.0 at the structural level:
- The Ed25519 signature satisfies VC proof requirements
- `cr3st4n1.version` maps to `@context` + `type` fields (when present)
- `identity` maps to `credentialSubject`
- `_signature` maps to `proof`
- `trust.credential_chain` maps to `issuer` chain
- Add OPTIONAL `@context` and `type` fields for VC interop mode

The .cr3st4n1 file remains valid YAML without W3C fields (backwards compatible). Adding `@context` and `type` fields makes it ALSO a valid W3C VC (dual-mode).

DID method: `did:m3m3tic:<sha256-of-credential>` or `did:web:bonfire.dev:<actor-id>`

## Consequences
- .cr3st4n1 files can be stored in EUDI Wallets (Dec 2026 onwards)
- Bonfire Terminal becomes a VC Issuer in the W3C ecosystem
- Cross-system verification possible (any VC verifier can check .cr3st4n1)
- Implementation work: add optional VC envelope fields, publish DID method spec
- Timeline: implement after Herbalife trial (Phase 6), target Q3-Q4 2026
