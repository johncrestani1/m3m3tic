# M3M3TIC Policy Interface
# Shared helper functions for all policy packs
# Version: 1.0.0
# All policies import this package for common utilities

package m3m3tic.policy.interface

# Check if a jurisdiction code is present in the audience geos
geo_applicable(geos, code) {
	geos[_] == code
}

# Check if any of a set of jurisdiction codes is present in audience geos
any_geo_applicable(geos, codes) {
	geo_applicable(geos, codes[_])
}

# Build a standard violation result object
# rule: string identifier (e.g., "ftc-endorsement-disclosure-001")
# severity: "block" | "warn" | "info"
# message: human-readable explanation
# jurisdiction: ISO code or "BRAND"
# remediation: actionable fix instruction
make_result(rule, severity, message, jurisdiction, remediation) = result {
	result := {
		"rule": rule,
		"severity": severity,
		"message": message,
		"jurisdiction": jurisdiction,
		"remediation": remediation,
	}
}

# Check if actor is compensated (any relationship with compensation)
actor_is_compensated(input) {
	input.relationship.compensation.model != ""
}

# Check if actor is compensated - alternate: compensation object exists
actor_is_compensated(input) {
	input.relationship.compensation
}

# Check if content has a specific disclosure type attached
has_disclosure(input, dtype) {
	input.content.disclosures_attached[_].type == dtype
}

# Check if content is AI-generated
content_is_ai_generated(input) {
	input.content.provenance.ai_generated == true
}

# Check if content is AI-assisted
content_is_ai_assisted(input) {
	input.content.provenance.ai_assisted == true
}

# Check if content involves any AI
content_involves_ai(input) {
	content_is_ai_generated(input)
}

content_involves_ai(input) {
	content_is_ai_assisted(input)
}

# Get all text content concatenated for text scanning
all_text(input) = text {
	text := concat(" ", [
		object.get(input.content.creative, "primary_text", ""),
		object.get(input.content.creative, "headline", ""),
		object.get(input.content.creative, "cta", ""),
	])
}

# Check if a string contains any term from a list (case-insensitive)
contains_any(text, terms) {
	term := terms[_]
	contains(lower(text), lower(term))
}
