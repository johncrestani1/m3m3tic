# Singapore PDPA and AI Governance Framework
# Law: Personal Data Protection Act 2012 (amended 2021)
# Additional: IMDA AI Governance Framework; MAS Guidelines on Fair Dealing
# Effective: 2021-02-01 (PDPA amendments); ongoing (AI framework)
# Regulator: PDPC (Personal Data Protection Commission); IMDA; MAS
# Source: https://www.pdpc.gov.sg/; https://www.imda.gov.sg/

package m3m3tic.policy.sg.pdpa_ai_governance

import rego.v1

# Applicable when Singapore is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "SG"
}

# Check if content uses behavioral targeting
uses_behavioral_targeting if {
    input.content.targeting.method == "behavioral"
}

uses_behavioral_targeting if {
    some method in input.content.targeting.methods
    method == "behavioral"
}

uses_behavioral_targeting if {
    input.content.targeting.uses_personal_data == true
}

# Check if PDPA consent has been obtained
has_pdpa_consent if {
    input.content.targeting.consent.pdpa == true
}

has_pdpa_consent if {
    input.content.targeting.consent.explicit == true
}

# Check if content is AI-generated
is_ai_generated if {
    input.content.identity.type == "ai_agent"
}

is_ai_generated if {
    input.content.ai_disclosure.is_ai_generated == true
}

# Check for AI disclosure
has_ai_disclosure if {
    input.content.ai_disclosure.labeled == true
}

has_ai_disclosure if {
    input.content.ai_disclosure.human_visible_label == true
}

# Check if content is financial advertising
is_financial_ad if {
    input.content.product.category == "financial_services"
}

is_financial_ad if {
    input.content.product.category == "investment"
}

is_financial_ad if {
    input.content.product.category == "cryptocurrency"
}

is_financial_ad if {
    some category in input.content.product.categories
    category == "financial_services"
}

# Check for FOMO exploitation in financial ads
exploits_fomo if {
    input.content.tactics.fomo == true
}

exploits_fomo if {
    input.content.tactics.urgency_artificial == true
}

exploits_fomo if {
    input.content.tactics.guaranteed_returns == true
}

# DENY: Behavioral targeting without PDPA consent
deny[result] if {
    applicable
    uses_behavioral_targeting
    not has_pdpa_consent
    result := {
        "rule": "sg_pdpa_consent_required",
        "severity": "high",
        "message": "PDPA requires explicit consent for collection and use of personal data for behavioral targeting of Singapore users. Consent must be obtained before data collection begins.",
        "jurisdiction": "SG",
        "remediation": "Obtain explicit PDPA-compliant consent from users before behavioral targeting. Consent must be informed, voluntary, and specific to the purpose. Set targeting.consent.pdpa=true only after valid consent obtained. Penalty: up to 10% of annual turnover or 1M SGD."
    }
}

# Advisory: AI-generated content disclosure recommended (not yet mandatory)
deny[result] if {
    applicable
    is_ai_generated
    not has_ai_disclosure
    result := {
        "rule": "sg_ai_disclosure_recommended",
        "severity": "low",
        "message": "Singapore's AI Governance Framework recommends disclosure of AI-generated content. While not yet legally mandatory, IMDA guidelines strongly encourage transparency about AI use in content creation.",
        "jurisdiction": "SG",
        "remediation": "Add AI content disclosure as a best practice. This is currently advisory but expected to become mandatory as Singapore's AI governance framework evolves. Set ai_disclosure.labeled=true and provide human-visible indicator."
    }
}

# DENY: Financial ads exploiting FOMO (MAS Guidelines)
deny[result] if {
    applicable
    is_financial_ad
    exploits_fomo
    result := {
        "rule": "sg_mas_no_fomo_exploitation",
        "severity": "high",
        "message": "MAS Guidelines on Fair Dealing prohibit financial advertisements that exploit fear of missing out (FOMO), create artificial urgency, or promise guaranteed returns. Financial promotions must be balanced and not misleading.",
        "jurisdiction": "SG",
        "remediation": "Remove FOMO-exploiting elements from financial advertisements. Do not use: artificial countdown timers, claims of guaranteed returns, 'limited spots' pressure tactics, or misleading performance claims. Include balanced risk disclosure. MAS can pursue criminal prosecution for serious violations."
    }
}

# DENY: Financial ads without balanced risk disclosure
deny[result] if {
    applicable
    is_financial_ad
    not input.content.disclosures.risk_warning == true
    result := {
        "rule": "sg_mas_risk_disclosure",
        "severity": "medium",
        "message": "MAS guidelines require financial advertisements to include balanced risk disclosures. Benefits cannot be presented without corresponding risk information.",
        "jurisdiction": "SG",
        "remediation": "Include clear risk warnings alongside any performance claims or benefit statements. Risk disclosure must be equally prominent as return/benefit claims. Set disclosures.risk_warning=true after adding appropriate disclaimers."
    }
}

# DENY: Foreign political interference via advertising (FICA)
deny[result] if {
    applicable
    input.content.category == "political"
    input.content.origin.foreign == true
    result := {
        "rule": "sg_fica_foreign_interference",
        "severity": "critical",
        "message": "The Foreign Interference (Countermeasures) Act (FICA) prohibits foreign entities from conducting political advertising or influence campaigns targeting Singapore. This is a criminal offense.",
        "jurisdiction": "SG",
        "remediation": "Foreign entities must not publish political content targeting Singapore audiences. This includes content about Singapore elections, government policy, or political parties. Violation carries criminal penalties including imprisonment."
    }
}
