# Quebec (Canada) - Charter of the French Language (Bill 96 / Loi 101)
# Version: 2024.0
# Effective: 1977-08-26 (original), 2022-06-01 (Bill 96 amendments)
# Source: https://www.legisquebec.gouv.qc.ca/en/document/cs/C-11
#
# The Charter of the French Language requires that all commercial advertising
# in Quebec be in French. Other languages may be used but French must be at least
# as prominent (markedly predominant per Bill 96 for signage; equal for advertising).
# OQLF enforces compliance.

package m3m3tic.policy.ca.quebec_french_language

import data.m3m3tic.policy.interface as iface

# Self-selection: applies when CA is in audience geos
# Note: ideally would check for QC specifically, but geo-targeting at provincial
# level uses CA + platform targeting. Policy triggers on CA and checks further.
applicable {
	iface.geo_applicable(input.content.audience.geos, "CA")
}

# Deny: content targeting Quebec without French version
deny[result] {
	applicable
	targets_quebec
	not has_french_content
	result := iface.make_result(
		"quebec-french-presence-001",
		"block",
		"Charter of the French Language (C-11) s.58: Commercial advertising in Quebec must be available in French. French must be at least equally prominent.",
		"CA-QC",
		"Provide a French-language version of all creative text. French must be at least as prominent as any other language in the advertisement.",
	)
}

# Warn: French content exists but may not be equally prominent
deny[result] {
	applicable
	targets_quebec
	has_french_content
	has_non_french_content
	not french_is_predominant
	result := iface.make_result(
		"quebec-french-prominence-002",
		"warn",
		"Charter of the French Language s.58.1 (Bill 96): French must be markedly predominant in commercial visibility. Ensure French text is at least equally prominent.",
		"CA-QC",
		"Ensure French version appears first, in equal or larger font size, and with equal visual weight. Bill 96 strengthened predominance requirements.",
	)
}

# Deny: trademark/slogan used without French equivalent or generic term
deny[result] {
	applicable
	targets_quebec
	not has_french_content
	uses_english_slogan
	result := iface.make_result(
		"quebec-french-slogan-003",
		"warn",
		"Charter of the French Language: English slogans/taglines in Quebec advertising should have a French equivalent unless registered as trademarks (limited exception).",
		"CA-QC",
		"Translate slogans and CTAs into French. Registered trademarks may appear in original language but surrounding text must be in French.",
	)
}

# Helper: determines if content is targeting Quebec specifically
targets_quebec {
	input.content.medium.platform == "meta"
	# Meta allows provincial targeting; if CA is in geos, Quebec is likely included
}

targets_quebec {
	input.content.medium.platform == "google"
}

targets_quebec {
	# Default: any CA-targeted campaign may reach Quebec (6M+ francophones)
	iface.geo_applicable(input.content.audience.geos, "CA")
}

has_french_content {
	disc := input.content.disclosures_attached[_]
	disc.type == "french_version"
}

has_french_content {
	disc := input.content.disclosures_attached[_]
	disc.type == "language"
	disc.method == "fr"
}

has_non_french_content {
	text := iface.all_text(input)
	count(text) > 0
	not all_french(text)
}

# Simplified check: assumes non-French if no french_only marker
all_french(text) {
	disc := input.content.disclosures_attached[_]
	disc.type == "language"
	disc.method == "fr_only"
}

french_is_predominant {
	disc := input.content.disclosures_attached[_]
	disc.type == "french_version"
	disc.method == "predominant"
}

uses_english_slogan {
	text := input.content.creative.cta
	count(text) > 0
}
