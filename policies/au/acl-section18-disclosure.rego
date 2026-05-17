# Australia - Australian Consumer Law (ACL) Section 18 & AANA Code of Ethics
# Version: 2024.0
# Effective: 2011-01-01 (ACL), AANA Code updated ongoing
# Source: https://www.legislation.gov.au/Details/C2022C00323 (Competition and Consumer Act 2010, Schedule 2)
# Source: https://aana.com.au/self-regulation/codes-guidelines/code-of-ethics/
#
# ACL Section 18: Prohibits misleading or deceptive conduct in trade or commerce.
# AANA Code: Distinguishable advertising, disclosure of commercial relationships,
# and influencer/affiliate transparency requirements.

package m3m3tic.policy.au.acl_section18_disclosure

import data.m3m3tic.policy.interface as iface

# Self-selection: applies when AU is in audience geos
applicable {
	iface.geo_applicable(input.content.audience.geos, "AU")
}

# Deny: compensated content not clearly identifiable as advertising (AANA)
deny[result] {
	applicable
	iface.actor_is_compensated(input)
	not has_ad_disclosure
	result := iface.make_result(
		"acl-aana-disclosure-001",
		"block",
		"AANA Code of Ethics S2.7 & Influencer Code: Advertising or marketing content must be clearly distinguishable as such. Commercial relationships must be disclosed.",
		"AU",
		"Add clear disclosure such as '#ad', 'Paid partnership', or 'Sponsored' in a prominent position. AANA requires upfront, unambiguous labeling.",
	)
}

# Deny: misleading claims (ACL Section 18 - misleading or deceptive conduct)
deny[result] {
	applicable
	claim := input.content.claims[_]
	claim.type == "factual"
	count(claim.evidence) == 0
	result := iface.make_result(
		"acl-s18-misleading-002",
		"warn",
		"ACL Section 18: Unsubstantiated factual claims may constitute misleading or deceptive conduct in trade or commerce. ACCC actively enforces.",
		"AU",
		"Substantiate the claim with evidence or add clear qualifiers. ACCC has issued infringement notices for social media claims without basis.",
	)
}

# Deny: testimonials without genuine experience basis (AANA 2.2)
deny[result] {
	applicable
	claim := input.content.claims[_]
	claim.type == "testimonial"
	count(claim.evidence) == 0
	result := iface.make_result(
		"acl-aana-testimonial-003",
		"warn",
		"AANA Code S2.2 & ACL: Testimonials must reflect genuine opinions based on actual experience. Fabricated testimonials are misleading conduct.",
		"AU",
		"Ensure testimonial is based on genuine product/service experience. Document the testimonial source and their actual usage.",
	)
}

# Deny: fine print contradicts headline claims (ACL Section 18)
deny[result] {
	applicable
	claim := input.content.claims[_]
	claim.type == "conditional"
	not has_qualification_disclosure
	result := iface.make_result(
		"acl-s18-fine-print-004",
		"warn",
		"ACL Section 18: Material conditions or limitations that contradict or significantly qualify headline claims must be prominently disclosed, not buried in fine print.",
		"AU",
		"Move material qualifications to a prominent position near the headline claim. ACCC guidance: if a qualification is necessary to prevent misleading impression, it must be equally prominent.",
	)
}

# Deny: absolute/guarantee claims without basis
deny[result] {
	applicable
	text := iface.all_text(input)
	iface.contains_any(text, ["guaranteed results", "risk free", "no exceptions", "always works"])
	result := iface.make_result(
		"acl-s18-absolute-005",
		"warn",
		"ACL Section 18: Absolute guarantees and unconditional claims are likely misleading unless fully substantiated and literally true.",
		"AU",
		"Remove absolute language or provide comprehensive substantiation. Add appropriate qualifiers reflecting actual limitations.",
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
}

has_qualification_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "qualification"
}

has_qualification_disclosure {
	disc := input.content.disclosures_attached[_]
	disc.type == "terms_conditions"
	disc.method == "prominent"
}
