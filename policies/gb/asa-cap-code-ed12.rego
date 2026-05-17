# UK Advertising Standards Authority - CAP Code (Non-broadcast) Edition 12
# Version: Ed12.2024
# Effective: 2014-09-01 (Edition 12), updated ongoing
# Source: https://www.asa.org.uk/codes-and-rulings/advertising-codes/non-broadcast-code.html
#
# The CAP Code requires that marketing communications be obviously identifiable
# as such. Paid-for content, affiliate content, and influencer ads must be clearly
# labelled. The ASA enforces via the CAP Code Sections 2 (Recognition) and 3 (Misleading).

package m3m3tic.policy.gb.asa_cap_code

import data.m3m3tic.policy.interface as iface

# Self-selection: applies when GB is in audience geos
applicable {
	iface.geo_applicable(input.content.audience.geos, "GB")
}

# Deny: compensated content without ad disclosure (CAP 2.1, 2.3)
deny[result] {
	applicable
	iface.actor_is_compensated(input)
	not has_ad_disclosure
	result := iface.make_result(
		"asa-cap-recognition-001",
		"block",
		"CAP Code 2.1/2.3: Marketing communications must be obviously identifiable as such. Paid/affiliate content requires clear 'Ad' or 'Advertisement' label.",
		"GB",
		"Add '#Ad' or '#Advertisement' at the start of the post. ASA requires upfront labeling — not buried in hashtags. Platform-native 'Paid partnership' labels are also acceptable.",
	)
}

# Deny: affiliate content without specific affiliate disclosure (CAP 2.4)
deny[result] {
	applicable
	input.relationship.type == "affiliate"
	not has_affiliate_disclosure
	result := iface.make_result(
		"asa-cap-affiliate-002",
		"warn",
		"CAP Code 2.4: Affiliate marketing content should make the commercial relationship clear, including the nature of the incentive.",
		"GB",
		"Add '#Ad' label AND clarify the affiliate relationship (e.g., 'I earn commission from purchases through this link').",
	)
}

# Deny: misleading claims without qualification (CAP 3.1)
deny[result] {
	applicable
	claim := input.content.claims[_]
	claim.type == "factual"
	count(claim.evidence) == 0
	result := iface.make_result(
		"asa-cap-misleading-003",
		"warn",
		"CAP Code 3.1: Marketing communications must not materially mislead. Factual claims require substantiation.",
		"GB",
		"Provide documentary evidence for the claim or add appropriate qualifications. Remove unsubstantiated factual assertions.",
	)
}

# Deny: exaggerated or absolute claims (CAP 3.11)
deny[result] {
	applicable
	text := iface.all_text(input)
	iface.contains_any(text, ["guaranteed", "100% success", "no risk", "always works", "never fails"])
	result := iface.make_result(
		"asa-cap-exaggeration-004",
		"warn",
		"CAP Code 3.11/3.33: Absolute guarantees and superlative performance claims are likely to mislead unless fully substantiated.",
		"GB",
		"Remove absolute terms or provide full substantiation. Consider adding qualifiers such as 'in our experience' or 'based on [study]'.",
	)
}

has_ad_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "ad_label"
}

has_ad_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "sponsorship"
}

has_ad_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "paid_partnership"
	disc.method == "platform_native"
}

has_affiliate_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "affiliate"
}

has_affiliate_disclosure {
	has_ad_disclosure
}
