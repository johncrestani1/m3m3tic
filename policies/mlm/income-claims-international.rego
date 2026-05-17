# MLM Income Claims — International Compliance Policy Pack
#
# Regulation: Multi-jurisdiction income opportunity claims for direct selling
# Covers: US (FTC Settlement + 16 CFR 437), EU (UCPD Annex I Item 14),
#          UK (ASA MLM Guidance), AU (ACL S18/S29 + 50% bright-line),
#          CA (Competition Act S55), JP (ASCT Chain Transactions),
#          KR (Door-to-Door Sales Act), CN (Direct Selling Regs 2005),
#          IN (Direct Selling Rules 2021), BR (CDC), FR (L122-6/7), DE (UWG)
# Version: 2026.1
# Effective: Composite (see per-jurisdiction dates below)
# Source: FTC.gov, EUR-Lex, ASA.org.uk, ACCC.gov.au, laws.justice.gc.ca,
#         japaneselawtranslation.go.jp, ftc.go.kr, mofcom.gov.cn
# Maintainer: bonfire-policy-team

package m3m3tic.policy.mlm.income_claims_international

import future.keywords.in
import future.keywords.if

# ═══════════════════════════════════════════════════════════
# APPLICABILITY — fires when content involves income/opportunity
# claims AND the entity structure is direct_selling/MLM
# ═══════════════════════════════════════════════════════════

applicable if {
    input.brand.entity.structure.model == "multi_level_marketing"
}

applicable if {
    input.brand.entity.structure.type == "direct_selling"
}

# ═══════════════════════════════════════════════════════════
# UNIVERSAL RULES (all jurisdictions where MLM operates)
# ═══════════════════════════════════════════════════════════

# Income claim without evidence = DENY everywhere
deny[result] if {
    applicable
    claim := input.content.claims[_]
    claim.category == "income"
    not has_income_evidence(claim)
    result := {
        "rule": "mlm-income-claim-unsubstantiated",
        "severity": "block",
        "message": "Income claim requires substantiation from official Income Disclosure Statement",
        "jurisdiction": "ALL",
        "remediation": "Attach IDS link and typicality statement to any income reference"
    }
}

# Recruitment-over-product emphasis = DENY everywhere
deny[result] if {
    applicable
    recruitment_focused(input.content)
    result := {
        "rule": "mlm-recruitment-focus",
        "severity": "block",
        "message": "Content emphasizes recruitment over product sales — violates MLM compliance globally",
        "jurisdiction": "ALL",
        "remediation": "Refocus content on product benefits and retail sales"
    }
}

# Always-prohibited income patterns (no evidence can save these)
deny[result] if {
    applicable
    text := all_content_text(input.content)
    pattern := always_prohibited_patterns[_]
    contains(lower(text), lower(pattern))
    result := {
        "rule": "mlm-absolute-income-prohibition",
        "severity": "block",
        "message": sprintf("Pattern '%s' is always prohibited for MLM distributors", [pattern]),
        "jurisdiction": "ALL",
        "remediation": "Remove this claim entirely. No substantiation can make it compliant."
    }
}

always_prohibited_patterns := [
    "replace your income", "quit your job", "financial freedom",
    "six figures", "unlimited earning", "get rich", "easy money",
    "passive income", "be your own boss", "ground floor",
    "risk-free", "guaranteed income", "no experience needed"
]

# ═══════════════════════════════════════════════════════════
# US-SPECIFIC (FTC Settlement + Business Opportunity Rule)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "US" in input.content.audience.geos
    claim := input.content.claims[_]
    claim.category == "income"
    not has_typicality_statement(input.content)
    result := {
        "rule": "us-ftc-herbalife-settlement-typicality",
        "severity": "block",
        "message": "US: Income claim requires typicality statement (FTC Settlement 2016)",
        "jurisdiction": "US",
        "remediation": "Add: 'Most distributors who pursue the business opportunity earn less than $200 per month'"
    }
}

deny[result] if {
    applicable
    "US" in input.content.audience.geos
    implies_lavish_lifestyle(input.content)
    result := {
        "rule": "us-ftc-lifestyle-claims",
        "severity": "block",
        "message": "US: Cannot suggest distributors enjoy lavish lifestyle from business (FTC Settlement)",
        "jurisdiction": "US",
        "remediation": "Remove lifestyle imagery/claims that imply wealth from the opportunity"
    }
}

# ═══════════════════════════════════════════════════════════
# EU-SPECIFIC (UCPD Annex I + country variations)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    eu_geo_present
    recruitment_compensation_primary(input.content)
    result := {
        "rule": "eu-ucpd-annex1-item14-pyramid",
        "severity": "block",
        "message": "EU: Content suggests compensation derives primarily from recruitment — banned practice (UCPD Annex I, Item 14)",
        "jurisdiction": "EU",
        "remediation": "Compensation messaging must emphasize retail product sales"
    }
}

# France: criminal liability for pyramid promotion
deny[result] if {
    applicable
    "FR" in input.content.audience.geos
    recruitment_focused(input.content)
    result := {
        "rule": "fr-code-consommation-l122",
        "severity": "block",
        "message": "France: Pyramid scheme promotion is criminal (Code de la consommation L122-6/7). Penalty: 1-2yr prison + EUR 300k",
        "jurisdiction": "FR",
        "remediation": "Remove ALL recruitment-focused language for French audience"
    }
}

# ═══════════════════════════════════════════════════════════
# UK-SPECIFIC (ASA/CAP MLM Guidance)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "GB" in input.content.audience.geos
    claim := input.content.claims[_]
    claim.category == "income"
    has_specific_figure(claim)
    not represents_average(claim)
    result := {
        "rule": "gb-asa-mlm-atypical-earnings",
        "severity": "block",
        "message": "UK: Income figures must represent what average person can earn (ASA MLM Guidance)",
        "jurisdiction": "GB",
        "remediation": "Use only average/typical figures or remove specific amounts"
    }
}

# ═══════════════════════════════════════════════════════════
# AUSTRALIA-SPECIFIC (ACL + 2026 bright-line test)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "AU" in input.content.audience.geos
    claim := input.content.claims[_]
    claim.category == "income"
    not includes_risk_disclosure(input.content)
    result := {
        "rule": "au-acl-s29-earnings-representation",
        "severity": "block",
        "message": "AU: False/misleading representations about earnings breach ACL Section 29. Penalty: AUD $1.1M+",
        "jurisdiction": "AU",
        "remediation": "Include risk disclosure: income not guaranteed, individual results vary"
    }
}

# ═══════════════════════════════════════════════════════════
# CANADA-SPECIFIC (Competition Act Section 55)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "CA" in input.content.audience.geos
    claim := input.content.claims[_]
    claim.category == "income"
    not has_fair_reasonable_disclosure(claim)
    result := {
        "rule": "ca-competition-act-s55-mlm-disclosure",
        "severity": "block",
        "message": "CA: Income representations to prospective participants require fair, reasonable and timely disclosure of typical earnings (Competition Act S55(2)). Criminal: up to 5yr prison.",
        "jurisdiction": "CA",
        "remediation": "Attach country-specific Income Disclosure Statement with typical earnings"
    }
}

# ═══════════════════════════════════════════════════════════
# JAPAN-SPECIFIC (ASCT chain transactions)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "JP" in input.content.audience.geos
    claim := input.content.claims[_]
    claim.category == "income"
    not product_centric_income(claim)
    result := {
        "rule": "jp-asct-article36-exaggerated-earnings",
        "severity": "block",
        "message": "JP: Exaggerated claims about potential earnings from recruitment are forbidden (ASCT Art. 36). Must show product-based income projections.",
        "jurisdiction": "JP",
        "remediation": "Income claims must be tied to product sales volumes, not recruitment"
    }
}

# ═══════════════════════════════════════════════════════════
# CHINA-SPECIFIC (Direct Selling Regulations 2005)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "CN" in input.content.audience.geos
    mentions_multi_level(input.content)
    result := {
        "rule": "cn-direct-selling-regs-single-level-only",
        "severity": "block",
        "message": "CN: Multi-level compensation structures are PROHIBITED in China. Only single-level direct selling with license is permitted. Compensation cannot exceed 30% of sales price.",
        "jurisdiction": "CN",
        "remediation": "China content must NEVER reference downline, team building, or multi-level income"
    }
}

# ═══════════════════════════════════════════════════════════
# KOREA-SPECIFIC (Door-to-Door Sales Act)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "KR" in input.content.audience.geos
    claim := input.content.claims[_]
    claim.category == "income"
    not has_average_income_disclosure(claim)
    result := {
        "rule": "kr-door-to-door-sales-income-disclosure",
        "severity": "block",
        "message": "KR: Must disclose potential earnings AND average income of participants (Door-to-Door Sales Act)",
        "jurisdiction": "KR",
        "remediation": "Include average participant income alongside any earnings claim"
    }
}

# ═══════════════════════════════════════════════════════════
# INDIA-SPECIFIC (Direct Selling Rules 2021)
# ═══════════════════════════════════════════════════════════

deny[result] if {
    applicable
    "IN" in input.content.audience.geos
    claim := input.content.claims[_]
    claim.category == "income"
    not substantiable(claim)
    result := {
        "rule": "in-direct-selling-rules-2021-income",
        "severity": "block",
        "message": "IN: Income claims must be capable of substantiation. Earnings must be based primarily on product sales, not recruitment (Direct Selling Rules 2021).",
        "jurisdiction": "IN",
        "remediation": "Provide verifiable evidence; link to official IDS"
    }
}

# ═══════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════

eu_geo_present if {
    geo := input.content.audience.geos[_]
    geo in {"EU", "DE", "FR", "ES", "IT", "NL", "BE", "AT", "PT", "IE", "PL", "SE", "DK", "FI", "CZ", "RO", "HU", "BG", "HR", "SK", "SI", "LT", "LV", "EE", "LU", "MT", "CY"}
}

has_income_evidence(claim) if {
    some e in claim.evidence
    e.type == "official_disclosure"
}

has_typicality_statement(content) if {
    some d in content.disclosures_attached
    d.type == "typicality_statement"
}

implies_lavish_lifestyle(content) if {
    text := all_content_text(content)
    pattern := lifestyle_patterns[_]
    contains(lower(text), lower(pattern))
}

lifestyle_patterns := [
    "luxury", "mansion", "sports car", "ferrari", "lamborghini",
    "yacht", "private jet", "designer", "rolex", "first class"
]

recruitment_focused(content) if {
    text := all_content_text(content)
    recruitment_terms := ["join my team", "build your team", "sign up under me",
                          "downline", "recruit", "enroll others", "grow your network"]
    term := recruitment_terms[_]
    contains(lower(text), lower(term))
}

recruitment_compensation_primary(content) if {
    text := all_content_text(content)
    contains(lower(text), "earn from your team")
}

recruitment_compensation_primary(content) if {
    text := all_content_text(content)
    contains(lower(text), "earn from recruiting")
}

has_specific_figure(claim) if {
    regex.match(`\$[\d,]+|\£[\d,]+|[\d,]+\s*(USD|GBP|EUR)`, claim.text)
}

represents_average(claim) if {
    contains(lower(claim.text), "average")
}

represents_average(claim) if {
    contains(lower(claim.text), "typical")
}

includes_risk_disclosure(content) if {
    some d in content.disclosures_attached
    d.type in {"risk_disclosure", "income_disclaimer", "typicality_statement"}
}

has_fair_reasonable_disclosure(claim) if {
    some e in claim.evidence
    e.type == "official_disclosure"
    e.jurisdiction == "CA"
}

product_centric_income(claim) if {
    contains(lower(claim.text), "product sales")
}

product_centric_income(claim) if {
    contains(lower(claim.text), "retail")
}

mentions_multi_level(content) if {
    text := all_content_text(content)
    ml_terms := ["downline", "team building", "multi-level",
                 "your network", "levels deep", "generations"]
    term := ml_terms[_]
    contains(lower(text), lower(term))
}

has_average_income_disclosure(claim) if {
    some e in claim.evidence
    e.type == "official_disclosure"
    e.includes_average == true
}

substantiable(claim) if {
    count(claim.evidence) > 0
}

all_content_text(content) := text if {
    text := concat(" ", [
        object.get(content.creative, "primary_text", ""),
        object.get(content.creative, "headline", ""),
        object.get(content.creative, "description", "")
    ])
}
