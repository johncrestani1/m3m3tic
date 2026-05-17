# People's Republic of China - Deep Synthesis Provisions (CAC/MIIT/MPS)
# Version: 2024.0
# Effective: 2023-01-10
# Source: http://www.cac.gov.cn/2022-12/11/c_1672221949354811.htm
#
# Provisions on the Management of Deep Synthesis Internet Information Services
# (Articles 17, 18): Content generated or edited using deep synthesis technology
# must be conspicuously labeled. Providers and users must not use deep synthesis
# to generate misleading content without marking.

package m3m3tic.policy.cn.deep_synthesis_ai_labeling

import data.m3m3tic.policy.interface as iface

# Self-selection: applies when CN is in audience geos
applicable {
	iface.geo_applicable(input.content.audience.geos, "CN")
}

# Deny: AI-generated content without label (Article 17.1)
deny[result] {
	applicable
	iface.content_is_ai_generated(input)
	not has_ai_label
	result := iface.make_result(
		"cn-deep-synthesis-label-001",
		"block",
		"Deep Synthesis Provisions Article 17: Content generated using deep synthesis (AI) must carry a conspicuous label indicating it is synthetically generated.",
		"CN",
		"Add a visible '本内容由AI生成' (This content is AI-generated) label. Must be prominent and not easily overlooked by viewers.",
	)
}

# Deny: AI-generated content without metadata marking (Article 17.2)
deny[result] {
	applicable
	iface.content_is_ai_generated(input)
	not has_machine_readable_mark
	result := iface.make_result(
		"cn-deep-synthesis-metadata-002",
		"block",
		"Deep Synthesis Provisions Article 17: Deep synthesis outputs must embed identifiers in metadata that cannot be easily removed.",
		"CN",
		"Embed AI-generation metadata in file headers or use digital watermarking technology compliant with GB/T standards.",
	)
}

# Warn: AI-assisted content should carry disclosure (Article 18 guidance)
deny[result] {
	applicable
	iface.content_is_ai_assisted(input)
	not iface.content_is_ai_generated(input)
	not has_ai_label
	result := iface.make_result(
		"cn-deep-synthesis-assisted-003",
		"warn",
		"Deep Synthesis Provisions: AI-assisted content (edited/modified by AI tools) should be disclosed per Article 18 guidance on information management.",
		"CN",
		"Consider adding disclosure that AI tools were used in content creation. Label with '本内容经AI辅助制作' (AI-assisted).",
	)
}

# Deny: AI-generated content used in advertising without combined disclosure
deny[result] {
	applicable
	iface.content_is_ai_generated(input)
	iface.actor_is_compensated(input)
	not has_combined_disclosure
	result := iface.make_result(
		"cn-deep-synthesis-ad-004",
		"block",
		"Deep Synthesis Provisions + Advertising Law: AI-generated advertising content requires both AI labeling and advertising disclosure.",
		"CN",
		"Combine AI generation label ('AI生成') with advertising disclosure ('广告'). Both must be conspicuously displayed.",
	)
}

has_ai_label {
	disc := input.content.disclosures_attached[_]
	disc.type == "ai_generated"
}

has_ai_label {
	disc := input.content.disclosures_attached[_]
	disc.type == "deep_synthesis"
}

has_machine_readable_mark {
	disc := input.content.disclosures_attached[_]
	disc.type == "ai_generated"
	disc.method == "watermark"
}

has_machine_readable_mark {
	disc := input.content.disclosures_attached[_]
	disc.type == "ai_generated"
	disc.method == "metadata"
}

has_machine_readable_mark {
	disc := input.content.disclosures_attached[_]
	disc.type == "ai_generated"
	disc.method == "c2pa"
}

has_combined_disclosure {
	has_ai_label
	has_ad_marker
}

has_ad_marker {
	disc := input.content.disclosures_attached[_]
	disc.type == "ad_label"
}

has_ad_marker {
	disc := input.content.disclosures_attached[_]
	disc.type == "sponsorship"
}
