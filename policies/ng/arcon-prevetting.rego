# Nigeria ARCON Pre-Vetting Requirement
# Law: Advertising Regulatory Council of Nigeria (ARCON) Act 2022
# Effective: 2022-05-25
# Regulator: Advertising Regulatory Council of Nigeria (ARCON)
# Source: https://arcon.gov.ng/
# Key requirement: ALL advertisements must receive ARCON pre-approval BEFORE publication

package m3m3tic.policy.ng.arcon_prevetting

import rego.v1

# Applicable when Nigeria is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "NG"
}

# Check for valid ARCON clearance ID
has_arcon_clearance if {
    input.content.regulatory_clearances.ng.clearance_id != null
    input.content.regulatory_clearances.ng.clearance_id != ""
}

# Check for registered practitioner
has_registered_practitioner if {
    input.content.regulatory_clearances.ng.practitioner_id != null
    input.content.regulatory_clearances.ng.practitioner_id != ""
}

# Check if content is commercial/advertising
is_advertisement if {
    input.content.compensation.model != "unpaid"
    input.content.compensation.model != "none"
    input.content.compensation.model != null
}

is_advertisement if {
    input.content.is_advertisement == true
}

is_advertisement if {
    input.content.type == "advertisement"
}

is_advertisement if {
    input.content.type == "endorsement"
}

# Check if clearance has expired
clearance_expired if {
    expiry := input.content.regulatory_clearances.ng.expiry_date
    expiry != null
    time.now_ns() > time.parse_rfc3339_ns(expiry)
}

# DENY: Advertisement without ARCON pre-vetting clearance
deny[result] if {
    applicable
    is_advertisement
    not has_arcon_clearance
    result := {
        "rule": "ng_arcon_prevetting_required",
        "severity": "critical",
        "message": "ALL advertisements targeting Nigerian audiences MUST receive ARCON pre-vetting approval BEFORE publication. This is a pre-publication requirement - content cannot be published first and approved later.",
        "jurisdiction": "NG",
        "remediation": "Submit advertisement to ARCON for pre-vetting through a registered advertising practitioner. Obtain clearance certificate with clearance_id. Add to regulatory_clearances.ng.clearance_id. Do NOT publish until clearance is received. Penalties: 100,000-500,000 NGN per offense."
    }
}

# DENY: No registered practitioner (foreign advertisers must use local agency)
deny[result] if {
    applicable
    is_advertisement
    has_arcon_clearance
    not has_registered_practitioner
    result := {
        "rule": "ng_arcon_registered_practitioner",
        "severity": "high",
        "message": "ARCON pre-vetting submissions must be made by a registered advertising practitioner. Foreign advertisers must engage a locally registered Nigerian advertising agency.",
        "jurisdiction": "NG",
        "remediation": "Engage a registered ARCON practitioner to submit the advertisement for pre-vetting. Add the practitioner's registration ID to regulatory_clearances.ng.practitioner_id. Foreign entities cannot self-submit."
    }
}

# DENY: ARCON clearance has expired
deny[result] if {
    applicable
    is_advertisement
    has_arcon_clearance
    clearance_expired
    result := {
        "rule": "ng_arcon_clearance_expired",
        "severity": "high",
        "message": "ARCON clearance certificate has expired. Content must not continue to be published with an expired clearance.",
        "jurisdiction": "NG",
        "remediation": "Obtain renewed ARCON clearance before continuing publication. Submit for re-vetting through registered practitioner. Update regulatory_clearances.ng.clearance_id and expiry_date with new certificate details."
    }
}

# DENY: AI-generated advertisement without ARCON clearance
deny[result] if {
    applicable
    is_advertisement
    input.content.identity.type == "ai_agent"
    not has_arcon_clearance
    result := {
        "rule": "ng_arcon_ai_content_prevetting",
        "severity": "critical",
        "message": "AI-generated advertisements are subject to the same ARCON pre-vetting requirements. The AI operator's registered practitioner must submit content for approval before publication.",
        "jurisdiction": "NG",
        "remediation": "AI-generated ads must go through identical ARCON pre-vetting process. The human operator/registered practitioner is responsible for submission. Obtain clearance_id before publication."
    }
}
