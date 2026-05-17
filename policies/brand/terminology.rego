# Brand Terminology Policy - Prohibited and Required Terms
# Version: 1.0.0
# Effective: Always (brand policy, not jurisdiction-specific)
# Source: Internal brand guidelines
#
# Enforces brand voice consistency by detecting prohibited terminology,
# competitor mentions, deprecated product names, and required brand-specific
# language. Always active regardless of jurisdiction.

package m3m3tic.policy.brand.terminology

import data.m3m3tic.policy.interface as iface

# Always applicable - brand policies are jurisdiction-neutral
applicable {
	true
}

# Deny: content uses prohibited terms from brand config
deny[result] {
	applicable
	text := iface.all_text(input)
	term := input.brand.terminology.prohibited[_]
	contains(lower(text), lower(term))
	result := iface.make_result(
		"brand-term-prohibited-001",
		"block",
		sprintf("Brand policy violation: Prohibited term '%s' detected in creative content.", [term]),
		"BRAND",
		sprintf("Remove or replace '%s' with approved brand terminology. Consult brand voice guidelines for alternatives.", [term]),
	)
}

# Warn: content uses deprecated terms
deny[result] {
	applicable
	text := iface.all_text(input)
	entry := input.brand.terminology.deprecated[_]
	contains(lower(text), lower(entry.term))
	result := iface.make_result(
		"brand-term-deprecated-002",
		"warn",
		sprintf("Brand policy: Deprecated term '%s' detected. Use '%s' instead.", [entry.term, entry.replacement]),
		"BRAND",
		sprintf("Replace '%s' with the current approved term '%s'.", [entry.term, entry.replacement]),
	)
}

# Deny: competitor brand names mentioned (unless in comparison context)
deny[result] {
	applicable
	text := iface.all_text(input)
	competitor := input.brand.terminology.competitors[_]
	contains(lower(text), lower(competitor))
	not is_comparison_content
	result := iface.make_result(
		"brand-term-competitor-003",
		"warn",
		sprintf("Brand policy: Competitor name '%s' mentioned outside of approved comparison context.", [competitor]),
		"BRAND",
		sprintf("Remove reference to '%s' or restructure as an approved competitive comparison with substantiation.", [competitor]),
	)
}

# Deny: brand name misspelled or wrong case
deny[result] {
	applicable
	text := concat(" ", [
		object.get(input.content.creative, "primary_text", ""),
		object.get(input.content.creative, "headline", ""),
		object.get(input.content.creative, "cta", ""),
	])
	misspelling := input.brand.terminology.misspellings[_]
	contains(text, misspelling)
	result := iface.make_result(
		"brand-term-misspelling-004",
		"block",
		sprintf("Brand policy: Brand name misspelling '%s' detected. Correct form is required.", [misspelling]),
		"BRAND",
		sprintf("Fix the misspelling '%s'. Use the exact approved brand name format from the style guide.", [misspelling]),
	)
}

# Warn: content tone does not match brand voice constraints
deny[result] {
	applicable
	text := iface.all_text(input)
	restricted_tone := input.brand.voice.restricted_phrases[_]
	contains(lower(text), lower(restricted_tone))
	result := iface.make_result(
		"brand-voice-tone-005",
		"warn",
		sprintf("Brand voice: Phrase '%s' does not align with approved brand tone.", [restricted_tone]),
		"BRAND",
		sprintf("Rephrase to avoid '%s'. Refer to brand voice guidelines for tone-appropriate alternatives.", [restricted_tone]),
	)
}

is_comparison_content {
	claim := input.content.claims[_]
	claim.type == "comparative"
}
