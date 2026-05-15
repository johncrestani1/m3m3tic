package m3m3tic.fda_supplement

# FDA DSHEA compliance rules for dietary supplement marketing
# Regulation: Dietary Supplement Health and Education Act (DSHEA) 1994
# Last updated: 2026-05-15

import future.keywords.in
import future.keywords.if

# DENY: Health claims are blocked but no FDA disclaimer exists
deny[msg] if {
    input.legal.fda.health_claims.disease_claims_blocked == true
    not has_fda_disclaimer
    msg := "FDA: disease claims are blocked but no FDA disclaimer is defined in legal.disclaimers"
}

has_fda_disclaimer if {
    some disclaimer in input.legal.disclaimers
    contains(lower(disclaimer.title), "fda")
}

# DENY: FDA disclaimer must contain the standard DSHEA language
deny[msg] if {
    some disclaimer in input.legal.disclaimers
    contains(lower(disclaimer.title), "fda")
    not contains(lower(disclaimer.text), "not been evaluated by the food and drug administration")
    msg := "FDA: FDA disclaimer must contain standard DSHEA language: 'These statements have not been evaluated by the Food and Drug Administration'"
}

# DENY: Good examples must not contain disease cure claims
deny[msg] if {
    input.legal.fda.health_claims.disease_claims_blocked == true
    some pattern in input.legal.fda.health_claims.blocked_patterns
    some example in input.brand.voice.good_examples
    contains(lower(example), lower(pattern))
    msg := sprintf("FDA VIOLATION: good_example '%s' contains blocked health claim pattern '%s'", [example, pattern])
}

# WARN: Supplement brands should have energy/caffeine disclosure
warn[msg] if {
    input.entity.vertical == "health"
    not has_energy_disclosure
    msg := "FDA: health vertical detected but no 'energy' trigger in required_disclosures (consider adding caffeine warning)"
}

has_energy_disclosure if {
    some disclosure in input.legal.required_disclosures
    disclosure.trigger == "energy"
}

# DENY: "FDA approved" in prohibited terms is required for supplement brands
deny[msg] if {
    input.entity.vertical == "health"
    not has_fda_approved_prohibition
    msg := "FDA: health vertical must prohibit the term 'FDA approved' — supplements are not FDA-approved"
}

has_fda_approved_prohibition if {
    some term in input.brand.terminology.prohibited_terms
    contains(lower(term.term), "fda approved")
}
