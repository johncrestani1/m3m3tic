# Governance

## Decision-Making

The .m3m3tic specification is currently maintained by Bonfire Terminal. During the draft phase (v0.x), all decisions are made by the core maintainers.

### Maintainers

| Name | Role | GitHub |
|---|---|---|
| Larry Crestani | Lead | @johncrestani1 |

### How Changes Are Made

1. **Spec changes**: Proposed via GitHub Issues, discussed, then implemented via PR
2. **Schema changes**: Must accompany a spec change with matching version bump
3. **Policy additions**: Can be proposed independently via PR
4. **Breaking changes**: Require a MAJOR version bump and migration guide

### Versioning

This project uses [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR**: Breaking changes (fields removed, types changed, required fields added)
- **MINOR**: New optional fields, new sections, new policy packs
- **PATCH**: Clarifications, typo fixes, example additions

Every release is tagged as `v0.1.0`, `v0.2.0`, etc. Pre-release versions use `-rc.1` suffix.

### Future Governance

When the specification reaches v1.0 and has external adopters, governance will expand to include:
- A Technical Steering Committee with external members
- A formal RFC process for spec changes
- Potential submission to a standards body (W3C Community Group or OASIS)
