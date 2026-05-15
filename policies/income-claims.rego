package m3m3tic.income_claims

# Income claims compliance rules
# Regulation: FTC MLM Act (16 CFR Part 437), Herbalife v. FTC Settlement (2016)
# Last updated: 2026-05-15

import future.keywords.in
import future.keywords.if

# DENY: MLM industry must have income claim rules
deny[msg] if {
    input.entity.industry == "mlm"
    not input.legal.income_claims
    msg := "INCOME: MLM industry requires legal.income_claims configuration"
}

# DENY: MLM must require earnings disclosure
deny[msg] if {
    input.entity.industry == "mlm"
    input.legal.income_claims
    not input.legal.income_claims.earnings_claims_require_disclosure
    msg := "INCOME: MLM industry must set earnings_claims_require_disclosure to true"
}

# DENY: Good examples must not contain income claim patterns
deny[msg] if {
    some pattern in input.legal.income_claims.prohibited_patterns
    some example in input.brand.voice.good_examples
    contains(lower(example), lower(pattern))
    msg := sprintf("INCOME VIOLATION: good_example '%s' contains prohibited income claim '%s'", [example, pattern])
}

# DENY: MLM must have income disclosure in disclaimers
deny[msg] if {
    input.entity.industry == "mlm"
    not has_income_disclaimer
    msg := "INCOME: MLM industry requires an income disclosure in legal.disclaimers"
}

has_income_disclaimer if {
    some disclaimer in input.legal.disclaimers
    contains(lower(disclaimer.title), "income")
}

# DENY: MLM must prohibit recruitment-over-product language
deny[msg] if {
    input.entity.industry == "mlm"
    not has_recruitment_prohibition
    msg := "INCOME: MLM industry should prohibit recruitment-focused language (e.g., 'join my team') per FTC MLM Act"
}

has_recruitment_prohibition if {
    some term in input.brand.terminology.prohibited_terms
    contains(lower(term.term), "join")
}

# WARN: MLM should have income trigger in required_disclosures
warn[msg] if {
    input.entity.industry == "mlm"
    not has_income_trigger
    msg := "INCOME: MLM industry should have an 'income' trigger in required_disclosures"
}

has_income_trigger if {
    some disclosure in input.legal.required_disclosures
    disclosure.trigger == "income"
}
