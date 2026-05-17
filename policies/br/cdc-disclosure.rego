# Brazil Consumer Defense Code (CDC) - Advertising Disclosure
# Law: Codigo de Defesa do Consumidor (CDC) Art. 36-37
# Additional: CONANDA Resolution 163/2014 (children's advertising)
# Effective: 1990-09-11 (CDC); 2014-04-04 (CONANDA)
# Regulator: SENACON (National Consumer Secretariat); CONAR (self-regulatory)
# Source: https://www.planalto.gov.br/ccivil_03/leis/l8078compilado.htm

package m3m3tic.policy.br.cdc_disclosure

import rego.v1

# Applicable when Brazil is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "BR"
}

# Accepted disclosure labels in Portuguese
accepted_labels := {"Publicidade", "publicidade", "Publi", "publi", "#publi", "#publicidade", "#Publi", "#Publicidade"}

# Check for valid Brazilian disclosure
has_valid_disclosure if {
    some label in input.content.disclosure.labels
    label in accepted_labels
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

# Check if audience includes children under 12
targets_children if {
    input.content.audience.min_age < 12
}

targets_children if {
    input.content.audience.category == "children"
}

targets_children if {
    some segment in input.content.audience.segments
    segment == "children"
}

targets_children if {
    some segment in input.content.audience.segments
    segment == "kids"
}

# Check if content is in Portuguese
is_portuguese if {
    input.content.language == "pt"
}

is_portuguese if {
    input.content.language == "pt-BR"
}

# DENY: Commercial content without proper Portuguese disclosure
deny[result] if {
    applicable
    is_commercial
    not has_valid_disclosure
    result := {
        "rule": "br_cdc_art36_disclosure",
        "severity": "high",
        "message": "CDC Art. 36 requires advertising to be identified 'easily and immediately' by consumers. Content must include Portuguese-language disclosure labels.",
        "jurisdiction": "BR",
        "remediation": "Add one of the accepted Portuguese disclosure labels: 'Publicidade', 'Publi', '#publi', or '#publicidade'. The label must be immediately visible without requiring any user interaction."
    }
}

# DENY: Commercial content not in Portuguese for Brazilian audience
deny[result] if {
    applicable
    is_commercial
    not is_portuguese
    result := {
        "rule": "br_cdc_language_requirement",
        "severity": "high",
        "message": "Consumer-facing advertising targeting Brazilian audiences must be in Portuguese (pt-BR). CDC requires clear consumer comprehension.",
        "jurisdiction": "BR",
        "remediation": "Provide content and all disclosure labels in Brazilian Portuguese (pt-BR). This includes the ad copy, terms, conditions, and disclosure labels."
    }
}

# DENY: Advertising directed at children under 12 (CONANDA near-total ban)
deny[result] if {
    applicable
    is_commercial
    targets_children
    result := {
        "rule": "br_conanda_children_ban",
        "severity": "critical",
        "message": "CONANDA Resolution 163/2014 establishes a near-total ban on advertising directed at children under 12 in Brazil. This includes direct targeting, use of children's characters, cartoon language, or placement in children's content.",
        "jurisdiction": "BR",
        "remediation": "Do not target commercial content at children under 12 in Brazil. Remove children's audience segments. If the product is for children, advertising must be directed at parents/guardians only, not the children themselves."
    }
}

# DENY: Disclosure exists but not identifiable "easily and immediately"
deny[result] if {
    applicable
    is_commercial
    has_valid_disclosure
    input.content.disclosure.placement == "end"
    result := {
        "rule": "br_cdc_art36_placement",
        "severity": "medium",
        "message": "CDC Art. 36 requires advertising to be identifiable 'easily and immediately' (facilmente e imediatamente). Disclosure placed at the end of content does not satisfy this requirement.",
        "jurisdiction": "BR",
        "remediation": "Move the disclosure label to the beginning of the content or to a prominent fixed position (e.g., first line, overlay, title prefix). The consumer must recognize it as advertising before engaging with the content."
    }
}

# DENY: Misleading advertising (Art. 37)
deny[result] if {
    applicable
    is_commercial
    input.content.claims.unsubstantiated == true
    result := {
        "rule": "br_cdc_art37_misleading",
        "severity": "critical",
        "message": "CDC Art. 37 prohibits misleading advertising (publicidade enganosa). Claims must be substantiated and not create false impressions about products or services.",
        "jurisdiction": "BR",
        "remediation": "Remove or substantiate all claims. Provide documentary evidence for factual assertions. Ensure no information is omitted that would affect consumer decision-making."
    }
}
