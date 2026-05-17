# ADR-006: Relationships as Scoped Modules Inside .m3m3tic

## Status
Accepted

## Context
Actors need authority grants. Options: (a) encode in .cr3st4n1, (b) separate .m3m3tic-sow file, (c) array inside .m3m3tic.

## Decision
Option (c). The brand owner declares relationships[] with actor_ref (hash of .cr3st4n1), type, compensation, authority, duration.

## Consequences
Brand controls who can act on its behalf. One actor can appear in multiple brands' .m3m3tic files with different authority. Credential stays pure.
