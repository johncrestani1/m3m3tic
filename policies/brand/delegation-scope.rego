# Brand Delegation Scope Policy - Actor Authority Boundaries
# Version: 1.0.0
# Effective: Always (brand policy, not jurisdiction-specific)
# Source: Internal delegation/authority framework
#
# Validates that actors operate within their delegated authority.
# Checks trust levels, spend limits, platform permissions, content type
# restrictions, and approval requirements. Always active.

package m3m3tic.policy.brand.delegation_scope

import data.m3m3tic.policy.interface as iface

# Always applicable - brand policies are jurisdiction-neutral
applicable {
	true
}

# Deny: spend exceeds actor's authorized limit
deny[result] {
	applicable
	input.content.spend_amount > 0
	max_spend := input.relationship.authority.max_spend
	input.content.spend_amount > max_spend
	result := iface.make_result(
		"delegation-spend-limit-001",
		"block",
		sprintf("Delegation violation: Spend amount $%d exceeds actor's authorized limit of $%d.", [input.content.spend_amount, max_spend]),
		"BRAND",
		sprintf("Reduce spend to within $%d limit or request authority elevation from brand admin.", [max_spend]),
	)
}

# Deny: actor trust level insufficient for operation
deny[result] {
	applicable
	required_level := input.relationship.authority.min_trust_for_action
	input.actor.trust_level < required_level
	result := iface.make_result(
		"delegation-trust-level-002",
		"block",
		sprintf("Delegation violation: Actor trust level %d is below the required level %d for this action.", [input.actor.trust_level, required_level]),
		"BRAND",
		"This action requires a higher trust level. Submit for manual approval or escalate to a higher-trust actor.",
	)
}

# Deny: platform not in actor's allowed platforms
deny[result] {
	applicable
	allowed := input.relationship.authority.allowed_platforms
	count(allowed) > 0
	platform := input.content.medium.platform
	not platform_allowed(platform, allowed)
	result := iface.make_result(
		"delegation-platform-003",
		"block",
		sprintf("Delegation violation: Actor is not authorized to publish on platform '%s'.", [platform]),
		"BRAND",
		sprintf("This actor is authorized for platforms: %s. Request platform authorization or reassign to an authorized actor.", [concat(", ", allowed)]),
	)
}

# Deny: geo targeting outside actor's authorized regions
deny[result] {
	applicable
	allowed_geos := input.relationship.authority.allowed_geos
	count(allowed_geos) > 0
	target_geo := input.content.audience.geos[_]
	not geo_allowed(target_geo, allowed_geos)
	result := iface.make_result(
		"delegation-geo-scope-004",
		"block",
		sprintf("Delegation violation: Actor is not authorized to target geo '%s'.", [target_geo]),
		"BRAND",
		sprintf("Remove '%s' from target geos or request geo authorization. Actor is approved for: %s.", [target_geo, concat(", ", allowed_geos)]),
	)
}

# Warn: high spend requires approval workflow
deny[result] {
	applicable
	input.content.spend_amount > 0
	approval_threshold := input.relationship.authority.approval_threshold
	input.content.spend_amount > approval_threshold
	not has_approval
	result := iface.make_result(
		"delegation-approval-required-005",
		"warn",
		sprintf("Delegation notice: Spend of $%d exceeds approval threshold of $%d. Manual approval required.", [input.content.spend_amount, approval_threshold]),
		"BRAND",
		"Submit creative for brand manager approval before publishing. Attach spend justification and expected ROI.",
	)
}

# Deny: content type not in actor's allowed types
deny[result] {
	applicable
	allowed_types := input.relationship.authority.allowed_content_types
	count(allowed_types) > 0
	content_type := input.content.medium.placement
	not type_allowed(content_type, allowed_types)
	result := iface.make_result(
		"delegation-content-type-006",
		"warn",
		sprintf("Delegation violation: Actor is not authorized for content type '%s'.", [content_type]),
		"BRAND",
		sprintf("This actor is authorized for content types: %s. Request additional permissions or use an authorized format.", [concat(", ", allowed_types)]),
	)
}

platform_allowed(platform, allowed) {
	allowed[_] == platform
}

geo_allowed(geo, allowed) {
	allowed[_] == geo
}

type_allowed(content_type, allowed) {
	allowed[_] == content_type
}

has_approval {
	input.relationship.authority.approved == true
}
