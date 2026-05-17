# Saudi Arabia Mawthooq Platform - Commercial Content Creator Licensing
# Law: E-Commerce Law 2019; Ministry of Commerce Regulations
# Platform: Mawthooq (موثوق) - verified content creator registry
# Effective: 2023-01-01 (enforcement phase)
# Regulator: Ministry of Commerce and Investment; MCSGA
# Source: https://mc.gov.sa/

package m3m3tic.policy.sa.mawthooq

import rego.v1

# Applicable when Saudi Arabia is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "SA"
}

# Check for valid Mawthooq license
has_mawthooq_license if {
    input.content.regulatory_clearances.sa.mawthooq_id != null
    input.content.regulatory_clearances.sa.mawthooq_id != ""
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

# Islamic content compliance checks
violates_islamic_compliance if {
    input.content.content_sensitivity_flags.alcohol == true
}

violates_islamic_compliance if {
    input.content.content_sensitivity_flags.gambling == true
}

violates_islamic_compliance if {
    input.content.content_sensitivity_flags.pork_products == true
}

violates_islamic_compliance if {
    input.content.content_sensitivity_flags.religious_disrespect == true
}

violates_islamic_compliance if {
    input.content.content_sensitivity_flags.sexual_content == true
}

violates_islamic_compliance if {
    input.content.content_sensitivity_flags.gender_mixing_inappropriate == true
}

violates_islamic_compliance if {
    some category in input.content.categories
    category == "alcohol_promotion"
}

violates_islamic_compliance if {
    some category in input.content.categories
    category == "gambling_promotion"
}

violates_islamic_compliance if {
    some category in input.content.categories
    category == "adult_content"
}

# DENY: Commercial content without Mawthooq license
deny[result] if {
    applicable
    is_commercial
    not has_mawthooq_license
    result := {
        "rule": "sa_mawthooq_license_required",
        "severity": "critical",
        "message": "All commercial content creators targeting Saudi audiences must hold a valid Mawthooq (موثوق) license from the Ministry of Commerce. This applies to individuals, organizations, and AI-operated accounts alike.",
        "jurisdiction": "SA",
        "remediation": "Register on the Mawthooq platform (mc.gov.sa) and obtain a valid license ID. Add the license to regulatory_clearances.sa.mawthooq_id. Unlicensed commercial activity carries fines up to 1M SAR and potential business closure."
    }
}

# DENY: Content violating Islamic compliance requirements
deny[result] if {
    applicable
    violates_islamic_compliance
    result := {
        "rule": "sa_islamic_content_compliance",
        "severity": "critical",
        "message": "Content targeting Saudi audiences must comply with Islamic values and Saudi societal norms. Prohibited content includes: alcohol promotion, gambling, pork products, sexually explicit material, religious disrespect, and inappropriate gender mixing.",
        "jurisdiction": "SA",
        "remediation": "Remove all content elements that conflict with Islamic values and Saudi regulations. This includes any promotion of alcohol, gambling, pork products, sexual content, or material that could be interpreted as disrespecting Islam. Penalties include fines up to 1M SAR and deportation for non-citizens."
    }
}

# DENY: AI-generated commercial content without Mawthooq
deny[result] if {
    applicable
    is_commercial
    input.content.identity.type == "ai_agent"
    not has_mawthooq_license
    result := {
        "rule": "sa_mawthooq_ai_operator",
        "severity": "critical",
        "message": "AI-operated accounts publishing commercial content to Saudi audiences must be registered under the operator's Mawthooq license. The human/organization operator bears full liability.",
        "jurisdiction": "SA",
        "remediation": "Register the AI operator entity on Mawthooq. The operator_ref in ai_agent_metadata must correspond to a valid Mawthooq license holder. Add license to regulatory_clearances.sa.mawthooq_id."
    }
}

# DENY: Missing Arabic language for consumer-facing ads
deny[result] if {
    applicable
    is_commercial
    input.content.language != "ar"
    input.content.language != "ar-SA"
    not input.content.bilingual_ar == true
    result := {
        "rule": "sa_arabic_language_preferred",
        "severity": "medium",
        "message": "Commercial content targeting Saudi audiences should include Arabic language. While not an absolute ban on other languages, Arabic is strongly preferred and may be required by specific sector regulations.",
        "jurisdiction": "SA",
        "remediation": "Provide Arabic (ar-SA) version of commercial content, or ensure bilingual presentation with Arabic as primary language. Set content.bilingual_ar=true if Arabic version is included alongside other languages."
    }
}
