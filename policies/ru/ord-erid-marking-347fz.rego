# Russian Federation - Federal Law No. 347-FZ (ORD / ERID Advertising Marking)
# Version: 2024.0
# Effective: 2022-09-01 (amended 2023-09-01 with mandatory ERID)
# Source: http://publication.pravo.gov.ru/Document/View/0001202207020024
#
# All internet advertising in Russia must be registered with an OРД (advertising data
# operator), carry an ERID (electronic identifier) token, and display the "Реклама"
# (Advertisement) label with advertiser identification.

package m3m3tic.policy.ru.ord_erid_marking

import data.m3m3tic.policy.interface as iface

# Self-selection: applies when RU is in audience geos
applicable {
	iface.geo_applicable(input.content.audience.geos, "RU")
}

# Deny: paid content without ERID token
deny[result] {
	applicable
	is_advertising
	not has_erid_token
	result := iface.make_result(
		"ord-erid-token-001",
		"block",
		"347-FZ: All internet advertising must carry an ERID (electronic resource identifier) token obtained from a registered ORD operator.",
		"RU",
		"Register the creative with an ORD operator (e.g., Yandex OРД, VK OРД, Ozone ORD) and embed the returned ERID token in the ad creative or metadata.",
	)
}

# Deny: paid content without 'Реклама' label
deny[result] {
	applicable
	is_advertising
	not has_reklama_label
	result := iface.make_result(
		"ord-reklama-label-002",
		"block",
		"347-FZ: Internet advertising must display the word 'Реклама' (Advertisement) clearly in the creative.",
		"RU",
		"Add the text 'Реклама' in a visible position within the creative. It must be readable and not obscured.",
	)
}

# Deny: paid content without advertiser INN/name disclosure
deny[result] {
	applicable
	is_advertising
	not has_advertiser_id
	result := iface.make_result(
		"ord-advertiser-id-003",
		"block",
		"347-FZ: Advertising must identify the advertiser (name or INN/ОГРН).",
		"RU",
		"Include the advertiser's legal name or INN (taxpayer identification number) alongside the 'Реклама' label.",
	)
}

# Warn: content may be advertising but is not marked
deny[result] {
	applicable
	iface.actor_is_compensated(input)
	input.content.spend_amount == 0
	not has_erid_token
	result := iface.make_result(
		"ord-erid-compensated-004",
		"warn",
		"347-FZ: Compensated influencer content may constitute advertising under Russian law and require ERID registration even without direct spend.",
		"RU",
		"Consult with ORD operator to determine if this compensated content requires registration. When in doubt, register and obtain ERID.",
	)
}

is_advertising {
	input.content.spend_amount > 0
}

is_advertising {
	input.relationship.compensation.model != ""
	input.content.spend_amount > 0
}

has_erid_token {
	disc := input.content.disclosures_attached[_]
	disc.type == "erid"
}

has_reklama_label {
	disc := input.content.disclosures_attached[_]
	disc.type == "ad_label"
	disc.method == "reklama"
}

has_reklama_label {
	disc := input.content.disclosures_attached[_]
	disc.type == "reklama"
}

has_advertiser_id {
	disc := input.content.disclosures_attached[_]
	disc.type == "advertiser_identity"
}

has_advertiser_id {
	disc := input.content.disclosures_attached[_]
	disc.type == "payer_identity"
}
