# UAE Media License and Advertising Compliance
# Law: Federal Decree-Law No. 34/2023 on Combatting Rumours and Cybercrimes
# Additional: National Media Council (NMC) Resolution No. 20/2010; Influencer Licensing 2022
# Effective: 2022-06-01 (influencer licensing); 2023-01-02 (Decree-Law 34)
# Regulator: UAE National Media Council / Media Regulatory Office
# Source: https://nmc.gov.ae/

package m3m3tic.policy.ae.media_license

import rego.v1

# Applicable when UAE is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "AE"
}

# Check for valid UAE media permit
has_valid_permit if {
    input.content.regulatory_clearances.ae.permit_number != null
    input.content.regulatory_clearances.ae.permit_number != ""
}

# Check if content is commercial
is_commercial if {
    input.content.compensation.model != "unpaid"
    input.content.compensation.model != "none"
    input.content.compensation.model != null
}

is_commercial if {
    input.content.is_advertisement == true
}

# Content categories that violate UAE societal values
prohibited_content_types := {"alcohol_promotion", "gambling_promotion", "adult_content", "anti_government", "religious_disrespect", "defamation_state"}

# Check for prohibited content
contains_prohibited_content if {
    some content_type in input.content.categories
    content_type in prohibited_content_types
}

contains_prohibited_content if {
    input.content.content_sensitivity_flags.alcohol == true
}

contains_prohibited_content if {
    input.content.content_sensitivity_flags.gambling == true
}

contains_prohibited_content if {
    input.content.content_sensitivity_flags.religious_disrespect == true
}

# DENY: Commercial content without UAE media permit
deny[result] if {
    applicable
    is_commercial
    not has_valid_permit
    result := {
        "rule": "ae_media_license_required",
        "severity": "critical",
        "message": "All commercial content creators targeting UAE audiences must hold a valid UAE Media Council advertising permit. Influencer licensing has been mandatory since June 2022.",
        "jurisdiction": "AE",
        "remediation": "Obtain a UAE Media Council e-Media license/permit before publishing commercial content. Register at nmc.gov.ae. Add the permit number to regulatory_clearances.ae.permit_number. Non-citizens face deportation risk for violations."
    }
}

# DENY: Content disrespecting religion, government, or societal values
deny[result] if {
    applicable
    contains_prohibited_content
    result := {
        "rule": "ae_societal_values_compliance",
        "severity": "critical",
        "message": "Content must not disrespect religion, government institutions, or UAE societal values. This includes promotion of alcohol, gambling, adult content, or any material deemed offensive to public morals under Federal Decree-Law 34/2023.",
        "jurisdiction": "AE",
        "remediation": "Remove all content that could be interpreted as disrespecting religion, government, or societal values. This includes: alcohol/gambling promotion, religious criticism, government criticism, sexually explicit material. Penalties include fines up to 500,000 AED and deportation for non-citizens."
    }
}

# DENY: AI-generated content without proper licensing (same rules apply)
deny[result] if {
    applicable
    is_commercial
    input.content.identity.type == "ai_agent"
    not has_valid_permit
    result := {
        "rule": "ae_ai_content_license",
        "severity": "critical",
        "message": "AI-generated commercial content is subject to the same UAE Media Council licensing requirements as human-created content. The operator/deployer must hold the appropriate media license.",
        "jurisdiction": "AE",
        "remediation": "The AI content operator must obtain a UAE Media Council permit. The operator_ref entity in ai_agent_metadata must be the license holder. Add permit to regulatory_clearances.ae.permit_number."
    }
}

# DENY: Missing advertiser identification
deny[result] if {
    applicable
    is_commercial
    input.content.advertiser.name == null
    result := {
        "rule": "ae_advertiser_identification",
        "severity": "high",
        "message": "UAE advertising regulations require clear identification of the advertiser/brand behind commercial content.",
        "jurisdiction": "AE",
        "remediation": "Include clear advertiser identification in the content. The brand/company commissioning the advertisement must be identifiable to consumers."
    }
}
