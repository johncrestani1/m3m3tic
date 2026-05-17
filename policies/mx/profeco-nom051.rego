# Mexico PROFECO and NOM-051 Food Labeling Extension
# Law: Ley Federal de Proteccion al Consumidor (LFPC); NOM-051-SCFI/SSA1-2010 (amended 2025)
# Additional: PROFECO Guidelines on Influencer Advertising
# Effective: 2020-10-01 (NOM-051 Phase 1); 2025 (social media extension)
# Regulator: PROFECO (Federal Consumer Protection Agency); Ministry of Economy
# Source: https://www.gob.mx/profeco

package m3m3tic.policy.mx.profeco_nom051

import rego.v1

# Applicable when Mexico is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "MX"
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

# Accepted disclosure labels (Spanish required)
accepted_labels := {"#PublicidadPagada", "#Publicidad", "#publicidadpagada", "#publicidad", "Publicidad Pagada", "Publicidad", "Advertising", "#Advertising"}

# Check for valid disclosure
has_valid_disclosure if {
    some label in input.content.disclosure.labels
    label in accepted_labels
}

# Check if product is food/beverage
is_food_beverage if {
    input.content.product.category == "food"
}

is_food_beverage if {
    input.content.product.category == "beverage"
}

is_food_beverage if {
    input.content.product.category == "food_beverage"
}

is_food_beverage if {
    some cat in input.content.product.categories
    cat == "food"
}

is_food_beverage if {
    some cat in input.content.product.categories
    cat == "beverage"
}

# NOM-051 warning categories
nom051_warnings := {"excess_sugar", "excess_sodium", "excess_calories", "excess_fat", "excess_trans_fat", "contains_caffeine", "contains_sweeteners"}

# Check if product requires NOM-051 warnings
requires_nom051_warnings if {
    is_food_beverage
    some warning in input.content.product.nom051_warnings
    warning in nom051_warnings
}

requires_nom051_warnings if {
    is_food_beverage
    input.content.product.nom051_applicable == true
}

# Check if NOM-051 warnings are displayed
has_nom051_warnings if {
    input.content.product.nom051_labels_displayed == true
}

has_nom051_warnings if {
    count(input.content.product.displayed_warnings) > 0
}

# Check if content is in Spanish
is_spanish if {
    input.content.language == "es"
}

is_spanish if {
    input.content.language == "es-MX"
}

# Check if audience includes children
targets_children if {
    input.content.audience.min_age < 12
}

targets_children if {
    input.content.audience.category == "children"
}

# DENY: Commercial content without proper Spanish disclosure
deny[result] if {
    applicable
    is_commercial
    not has_valid_disclosure
    result := {
        "rule": "mx_profeco_disclosure_required",
        "severity": "high",
        "message": "PROFECO requires clear disclosure of commercial content. Accepted labels include #PublicidadPagada or #Publicidad. Spanish language preferred for disclosure labels.",
        "jurisdiction": "MX",
        "remediation": "Add '#PublicidadPagada' or '#Publicidad' as a disclosure label. The label must be visible and in Spanish for Mexican audiences. Place prominently at beginning of content."
    }
}

# DENY: Commercial content not in Spanish
deny[result] if {
    applicable
    is_commercial
    not is_spanish
    result := {
        "rule": "mx_spanish_language_required",
        "severity": "high",
        "message": "Consumer-facing advertising targeting Mexican audiences must be in Spanish per LFPC requirements.",
        "jurisdiction": "MX",
        "remediation": "Provide content in Spanish (es-MX) for Mexican audiences. All consumer-facing advertising copy, disclosures, terms, and conditions must be in Spanish."
    }
}

# DENY: Food/beverage social media promotion without NOM-051 warnings
deny[result] if {
    applicable
    is_commercial
    requires_nom051_warnings
    not has_nom051_warnings
    result := {
        "rule": "mx_nom051_social_media_warnings",
        "severity": "critical",
        "message": "NOM-051-SCFI/SSA1-2010 (amended 2025) extends warning label requirements to social media promotion of food and beverage products. Products with excess sugar, sodium, calories, fat, or trans fat must display octagonal warning labels even in social media ads.",
        "jurisdiction": "MX",
        "remediation": "Display required NOM-051 octagonal warning labels in social media content promoting food/beverage products. Warnings must be clearly visible. Include all applicable warnings: excess sugar, excess sodium, excess calories, excess fat, excess trans fat, contains caffeine, contains sweeteners. Fines up to 4.5M MXN."
    }
}

# DENY: Food/beverage advertising targeting children with NOM-051 products
deny[result] if {
    applicable
    is_commercial
    is_food_beverage
    requires_nom051_warnings
    targets_children
    result := {
        "rule": "mx_nom051_children_restriction",
        "severity": "critical",
        "message": "NOM-051 prohibits the use of cartoon characters, celebrities appealing to children, or direct child targeting for food/beverage products that carry warning labels.",
        "jurisdiction": "MX",
        "remediation": "Do not target food/beverage advertising at children under 12 if the product carries any NOM-051 warning labels. Remove children's characters, cartoon mascots, or child-appeal elements from the content."
    }
}

# DENY: Food advertising with unsubstantiated health claims
deny[result] if {
    applicable
    is_food_beverage
    is_commercial
    input.content.claims.health_claim == true
    not input.content.claims.health_claim_substantiated == true
    result := {
        "rule": "mx_profeco_health_claims",
        "severity": "high",
        "message": "Health claims in food/beverage advertising must be substantiated and comply with COFEPRIS regulations. Unsubstantiated health claims are prohibited.",
        "jurisdiction": "MX",
        "remediation": "Remove unsubstantiated health claims or provide COFEPRIS-compliant substantiation. Health claims must be backed by scientific evidence and comply with Mexican food safety regulations."
    }
}
