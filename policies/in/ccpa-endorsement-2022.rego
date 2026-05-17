# India CCPA Endorsement Guidelines 2022
# Law: Guidelines for Prevention of Misleading Advertisements and Endorsements for Misleading Advertisements 2022
# Additional: Drugs and Magic Remedies (DMR) Objectionable Advertisements Act 1954
# Effective: 2022-06-09
# Regulator: Central Consumer Protection Authority (CCPA); ASCI (self-regulatory)
# Source: https://consumeraffairs.nic.in/

package m3m3tic.policy.in.ccpa_endorsement_2022

import rego.v1

# Applicable when India is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "IN"
}

# Accepted disclosure labels
accepted_labels := {"#ad", "#sponsored", "#collaboration", "#partnership", "#Ad", "#Sponsored", "#Collaboration", "#Partnership", "Ad", "Sponsored", "Paid Partnership"}

# 54 disease categories banned under DMR Act
dmr_banned_categories := {
    "AIDS", "asthma", "blindness", "bronchial_asthma", "cancer",
    "cataract", "deafness", "diabetes", "epilepsy", "gangrene",
    "glaucoma", "heart_disease", "hernia", "high_blood_pressure",
    "hydrocele", "hysteria", "insanity", "kidney_stones", "leprosy",
    "leucoderma", "leukaemia", "lockjaw", "mental_disorders",
    "obesity", "paralysis", "plague", "polio", "sexual_impotence",
    "smallpox", "stammer", "trachoma", "tuberculosis", "tumours",
    "typhoid", "ulcer_of_stomach", "venereal_diseases",
    "female_diseases", "fits", "form_change", "dropsy",
    "enlarged_prostate", "goitre", "baldness", "greying_hair",
    "improvement_height", "improvement_memory", "improvement_vision",
    "jaundice", "joint_pain", "liver_disorders", "menstrual_disorders",
    "piles", "rheumatism", "sexual_pleasure"
}

# Check for valid disclosure
has_valid_disclosure if {
    some label in input.content.disclosure.labels
    label in accepted_labels
}

# Check if content is commercial endorsement
is_endorsement if {
    input.content.compensation.model != "unpaid"
    input.content.compensation.model != "none"
    input.content.compensation.model != null
}

is_endorsement if {
    input.content.is_advertisement == true
}

is_endorsement if {
    input.content.type == "endorsement"
}

# Check if endorser has used the product (due diligence)
endorser_used_product if {
    input.content.endorser.product_experience == true
}

endorser_used_product if {
    input.content.endorser.due_diligence_completed == true
}

# Check if product falls under DMR banned categories
is_dmr_banned if {
    some category in input.content.product.health_categories
    category in dmr_banned_categories
}

is_dmr_banned if {
    input.content.product.category == "health_cure"
    some claim in input.content.product.claims
    claim in dmr_banned_categories
}

# DENY: Endorsement without proper disclosure labels
deny[result] if {
    applicable
    is_endorsement
    not has_valid_disclosure
    result := {
        "rule": "in_ccpa_disclosure_required",
        "severity": "high",
        "message": "CCPA Guidelines 2022 require prominent disclosure for all endorsements. Accepted labels: #ad, #sponsored, #collaboration, #partnership. Must appear upfront, not buried in content.",
        "jurisdiction": "IN",
        "remediation": "Add one of the accepted disclosure labels prominently at the beginning of the content: #ad, #sponsored, #collaboration, or #partnership. The label must be visible without requiring 'see more' or scrolling."
    }
}

# DENY: Endorser has not used the product (due diligence requirement)
deny[result] if {
    applicable
    is_endorsement
    not endorser_used_product
    result := {
        "rule": "in_ccpa_endorser_due_diligence",
        "severity": "high",
        "message": "CCPA Guidelines require endorsers to have actually used or experienced the product/service before endorsing it. The endorser must perform due diligence to verify claims.",
        "jurisdiction": "IN",
        "remediation": "Endorser must use/experience the product before endorsing. Document product usage with evidence (purchase receipt, usage logs, or signed attestation). Set endorser.due_diligence_completed=true only after verification."
    }
}

# DENY: Product in DMR banned disease categories
deny[result] if {
    applicable
    is_dmr_banned
    result := {
        "rule": "in_dmr_banned_disease_advertising",
        "severity": "critical",
        "message": "The Drugs and Magic Remedies (Objectionable Advertisements) Act prohibits advertising cures/treatments for 54 specified diseases. This is an absolute ban with no remediation through disclosure.",
        "jurisdiction": "IN",
        "remediation": "Do not advertise or endorse products claiming to cure, treat, or prevent any of the 54 DMR-listed disease categories to Indian audiences. This content cannot be published regardless of disclaimers."
    }
}

# DENY: Endorser liability notice missing (endorser can be banned 1-3 years)
deny[result] if {
    applicable
    is_endorsement
    input.content.endorser.liability_acknowledged != true
    input.content.claims.performance_claims == true
    result := {
        "rule": "in_ccpa_endorser_personal_liability",
        "severity": "medium",
        "message": "Under CCPA Guidelines, endorsers are PERSONALLY LIABLE for misleading endorsements. Endorsers making performance claims can be banned from endorsing for 1-3 years. Liability acknowledgment recommended.",
        "jurisdiction": "IN",
        "remediation": "Ensure endorser acknowledges personal liability. Endorser should verify all performance claims independently. Set endorser.liability_acknowledged=true. Note: endorser may face 1-year ban (first offense) or 3-year ban (subsequent) for misleading endorsements."
    }
}

# DENY: Surrogate advertising (using one product to promote banned product)
deny[result] if {
    applicable
    input.content.product.is_surrogate == true
    result := {
        "rule": "in_ccpa_surrogate_advertising_ban",
        "severity": "critical",
        "message": "Surrogate advertising (promoting a banned product through association with a permitted product sharing the same brand) is prohibited under CCPA Guidelines and Cable Television Networks Rules.",
        "jurisdiction": "IN",
        "remediation": "Do not use surrogate advertising techniques. Content promoting alcohol, tobacco, or other banned products through brand extension products (e.g., 'music CDs', 'soda water') is prohibited."
    }
}
