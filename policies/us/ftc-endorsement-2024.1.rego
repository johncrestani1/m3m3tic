# FTC Guides Concerning the Use of Endorsements and Testimonials in Advertising
# Version: 2024.1 (revised effective date June 2023, updated guidance 2024)
# Effective: 2023-06-29
# Source: https://www.ftc.gov/legal-library/browse/federal-register-notices/guides-concerning-use-endorsements-testimonials-advertising
#
# Requires clear and conspicuous disclosure of material connections between
# endorsers and advertisers. Applies to all compensated actors creating content
# targeting US audiences.

package m3m3tic.policy.us.ftc_endorsement

import data.m3m3tic.policy.interface as iface

# Self-selection: applies when US is in audience geos
applicable {
	iface.geo_applicable(input.content.audience.geos, "US")
}

# Deny: compensated actor without sponsorship/material-connection disclosure
deny[result] {
	applicable
	iface.actor_is_compensated(input)
	not has_material_disclosure
	result := iface.make_result(
		"ftc-endorsement-disclosure-001",
		"block",
		"Compensated endorser must clearly and conspicuously disclose material connection to advertiser (16 CFR Part 255)",
		"US",
		"Add a clear disclosure such as '#ad', '#sponsored', or 'Paid partnership' in a prominent position. Disclosure must be unavoidable — not buried in hashtags or below the fold.",
	)
}

# Deny: disclosure exists but uses inadequate method (e.g., buried in description)
deny[result] {
	applicable
	iface.actor_is_compensated(input)
	has_material_disclosure
	not disclosure_is_clear_and_conspicuous
	result := iface.make_result(
		"ftc-endorsement-disclosure-002",
		"warn",
		"Disclosure exists but may not meet FTC 'clear and conspicuous' standard. Must be hard to miss, not buried.",
		"US",
		"Move disclosure to the beginning of text or use platform-native paid partnership label. Avoid placing only in hashtag strings or 'more' truncation zones.",
	)
}

# Deny: claims without substantiation
deny[result] {
	applicable
	claim := input.content.claims[_]
	claim.type == "efficacy"
	count(claim.evidence) == 0
	result := iface.make_result(
		"ftc-endorsement-substantiation-003",
		"block",
		sprintf("Efficacy claim '%s' lacks substantiation evidence. FTC requires competent and reliable evidence.", [claim.text]),
		"US",
		"Attach clinical study, peer-reviewed evidence, or remove the efficacy claim entirely.",
	)
}

# Deny: testimonial implying typical results without disclosure
deny[result] {
	applicable
	claim := input.content.claims[_]
	claim.type == "testimonial"
	not has_typical_results_disclosure
	result := iface.make_result(
		"ftc-endorsement-typical-results-004",
		"warn",
		"Testimonial may imply typical results. FTC requires disclosure of generally expected results or clear 'results not typical' caveat.",
		"US",
		"Add 'Results not typical. Individual results vary.' or disclose the generally expected performance.",
	)
}

has_material_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "sponsorship"
}

has_material_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "material_connection"
}

has_material_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "paid_partnership"
}

disclosure_is_clear_and_conspicuous {
	disc := input.content.disclosures_attached[_]
	disc.type == "sponsorship"
	disc.method == "platform_native"
}

disclosure_is_clear_and_conspicuous {
	disc := input.content.disclosures_attached[_]
	disc.type == "paid_partnership"
	disc.method == "platform_native"
}

disclosure_is_clear_and_conspicuous {
	disc := input.content.disclosures_attached[_]
	disc.type == "material_connection"
	disc.method == "superimposed"
}

has_typical_results_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "typical_results"
}
