# EU Digital Services Act (DSA) - Advertising Transparency Requirements
# Version: 2024.0
# Effective: 2024-02-17 (full application to all platforms)
# Source: https://eur-lex.europa.eu/eli/reg/2022/2065/oj (Articles 26, 38, 39)
#
# All advertisements on online platforms must be clearly identifiable as such,
# with information about who paid and targeting parameters used.

package m3m3tic.policy.eu.dsa_ad_transparency

import data.m3m3tic.policy.interface as iface

# EU member state codes
eu_geos := [
	"AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR",
	"DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL",
	"PL", "PT", "RO", "SK", "SI", "ES", "SE",
]

# Self-selection: applies when any EU member state is in audience geos
applicable {
	iface.any_geo_applicable(input.content.audience.geos, eu_geos)
}

# Deny: paid content without ad label
deny[result] {
	applicable
	is_paid_content
	not has_ad_label
	result := iface.make_result(
		"dsa-ad-label-001",
		"block",
		"DSA Article 26(1): Advertisements must be clearly identifiable as such in real-time display.",
		"EU",
		"Add an unambiguous 'Advertisement' or 'Sponsored' label visible without user interaction. Use platform-native ad labeling where available.",
	)
}

# Deny: paid content without payer identification
deny[result] {
	applicable
	is_paid_content
	not has_payer_disclosure
	result := iface.make_result(
		"dsa-ad-payer-002",
		"block",
		"DSA Article 26(1)(a): Must display the natural or legal person on whose behalf the advertisement is presented.",
		"EU",
		"Include clear identification of the paying entity (brand/advertiser name) in the ad metadata or disclosure.",
	)
}

# Warn: paid content without targeting transparency
deny[result] {
	applicable
	is_paid_content
	input.content.spend_amount > 0
	not has_targeting_info
	result := iface.make_result(
		"dsa-ad-targeting-003",
		"warn",
		"DSA Article 26(1)(b): Meaningful information about main targeting parameters should be accessible.",
		"EU",
		"Ensure platform ad library includes targeting parameters (geo, age, interests). Provide this in ad metadata.",
	)
}

# Deny: targeting minors with advertising (Article 28)
deny[result] {
	applicable
	is_paid_content
	input.content.audience.age_min < 18
	result := iface.make_result(
		"dsa-minor-targeting-004",
		"block",
		"DSA Article 28: Providers shall not present advertisements based on profiling using personal data of minors.",
		"EU",
		"Set minimum audience age to 18+ or remove all profiling-based targeting parameters for this campaign.",
	)
}

is_paid_content {
	input.content.spend_amount > 0
}

is_paid_content {
	input.relationship.compensation.model != ""
}

has_ad_label {
	disc := input.content.disclosures_attached[_]
	disc.type == "ad_label"
}

has_ad_label {
	disc := input.content.disclosures_attached[_]
	disc.type == "sponsored"
	disc.method == "platform_native"
}

has_payer_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "payer_identity"
}

has_payer_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "paid_partnership"
}

has_targeting_info {
	disc := input.content.disclosures_attached[_]
	disc.type == "targeting_parameters"
}
