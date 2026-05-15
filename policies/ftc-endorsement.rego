package m3m3tic.ftc_endorsement

# FTC Endorsement Guides compliance rules
# Regulation: 16 CFR Part 255 (FTC Endorsement Guides)
# Last updated: 2026-05-15

import future.keywords.in
import future.keywords.if

# DENY: Endorsement disclosure is required but not configured
deny[msg] if {
    input.legal.ftc.endorsement_guides.disclosure_required == true
    count(input.legal.ftc.endorsement_guides.disclosure_terms) == 0
    msg := "FTC: endorsement disclosure is required but no disclosure_terms are defined"
}

# DENY: Bad examples contain prohibited terms
deny[msg] if {
    some term in input.brand.terminology.prohibited_terms
    some example in input.brand.voice.bad_examples
    contains(lower(example), lower(term.term))
    msg := sprintf("FTC: bad_example contains prohibited term '%s' — this is expected (bad examples demonstrate what NOT to do), but verify it is not used in actual copy", [term.term])
}

# WARN: Good examples should not contain prohibited terms
warn[msg] if {
    some term in input.brand.terminology.prohibited_terms
    some example in input.brand.voice.good_examples
    contains(lower(example), lower(term.term))
    msg := sprintf("FTC VIOLATION: good_example '%s' contains prohibited term '%s' — reason: %s", [example, term.term, term.reason])
}

# DENY: If endorsement disclosure applies to testimonials, required_disclosures must include a testimonial trigger
deny[msg] if {
    "testimonial" in input.legal.ftc.endorsement_guides.applies_to
    not has_testimonial_disclosure
    msg := "FTC: endorsement applies to testimonials but no required_disclosure with trigger 'testimonial' exists"
}

has_testimonial_disclosure if {
    some disclosure in input.legal.required_disclosures
    disclosure.trigger == "testimonial"
}

# WARN: Missing disclosure position
warn[msg] if {
    input.legal.ftc.endorsement_guides.disclosure_required == true
    not input.legal.ftc.endorsement_guides.disclosure_position
    msg := "FTC: disclosure_required is true but no disclosure_position is specified"
}
