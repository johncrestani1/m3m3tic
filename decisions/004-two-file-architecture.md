# ADR-004: Two File Types Only (.m3m3tic + .cr3st4n1)

## Status
Accepted

## Context
We considered .m3m3tic-sow as a third file. Rejected because relationships belong to the brand owner's declaration, not a separate signed artifact. Simpler mental model. One actor credential, one brand file per brand.

## Decision
Two file types. Relationships[] array inside .m3m3tic. No .m3m3tic-sow.

## Consequences
Brand file is larger but self-contained. Actor credentials are pure identity. Evaluation only needs 2 files + content + policies.
