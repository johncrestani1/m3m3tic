# ADR-008: identity.type Field (human | ai_agent | organization)

## Status
Accepted

## Context
UAE DIFC Regulation 10 defines "Deployer" + "Operator" for autonomous systems. Saudi gave citizenship to Sophia. Estonia building AI Residency. Microsoft building Entra Agent ID. Non-human actors are real.

## Decision
Add identity.type enum. AI agents MUST chain to a human operator via operator_ref. Liability always terminates at a human. No AI personhood.

## Consequences
.cr3st4n1 can credential AI agents. DIFC compliance built-in. Future-proof for eIDAS 2.0 EUDI Wallet extensions.
