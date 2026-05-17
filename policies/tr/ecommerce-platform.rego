# Turkey E-Commerce Platform and Influencer Regulations
# Law: E-Commerce Law No. 7416 (2022); Consumer Protection Law No. 6502
# Additional: Ministry of Commerce Influencer Guidelines
# Effective: 2022-07-07 (Law 7416); 2024 (platform obligations phased)
# Regulator: Ministry of Commerce; Advertising Board (Reklam Kurulu); BTK
# Source: https://www.ticaret.gov.tr/

package m3m3tic.policy.tr.ecommerce_platform

import rego.v1

# Applicable when Turkey is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "TR"
}

# Check if entity is a large platform (1M+ daily Turkish users)
is_large_platform if {
    input.content.platform.daily_turkish_users >= 1000000
}

is_large_platform if {
    input.content.platform.size_category == "large"
}

# Check for local representative
has_local_representative if {
    input.content.platform.tr_local_representative != null
    input.content.platform.tr_local_representative != ""
}

has_local_representative if {
    input.content.platform.local_representatives.tr != null
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

# Check for influencer disclosure
has_disclosure if {
    some label in input.content.disclosure.labels
    label != null
    label != ""
}

# Check advertising expenditure compliance (2% cap for marketplaces)
exceeds_ad_spend_cap if {
    input.content.platform.type == "marketplace"
    input.content.advertising_spend.percentage_of_transactions > 2.0
}

# DENY: Large platform without local representative
deny[result] if {
    applicable
    is_large_platform
    not has_local_representative
    result := {
        "rule": "tr_local_representative_required",
        "severity": "critical",
        "message": "Platforms with 1 million or more daily Turkish users must appoint a local representative in Turkey under E-Commerce Law No. 7416. Failure results in bandwidth throttling (50%, then 75%) and advertising bans.",
        "jurisdiction": "TR",
        "remediation": "Appoint a local representative in Turkey with authority to receive legal notices and comply with court orders. Register with the Ministry of Commerce. Add representative details to platform.tr_local_representative. Non-compliance leads to progressive bandwidth throttling up to 90%."
    }
}

# DENY: Influencer commercial content without disclosure
deny[result] if {
    applicable
    is_commercial
    not has_disclosure
    result := {
        "rule": "tr_influencer_disclosure",
        "severity": "high",
        "message": "Ministry of Commerce guidelines require influencers to clearly disclose commercial relationships. All sponsored content must be identifiable as advertising.",
        "jurisdiction": "TR",
        "remediation": "Add clear disclosure label to commercial content. Accepted formats: 'Reklam', 'Advertorial', or equivalent Turkish-language disclosure. The label must be immediately visible to consumers."
    }
}

# DENY: Marketplace platform exceeding advertising expenditure cap
deny[result] if {
    applicable
    exceeds_ad_spend_cap
    result := {
        "rule": "tr_ad_spend_cap",
        "severity": "high",
        "message": "E-Commerce Law 7416 caps advertising expenditure for marketplace platforms at 2% of transaction value. Exceeding this cap triggers regulatory action.",
        "jurisdiction": "TR",
        "remediation": "Reduce advertising expenditure to below 2% of total transaction value on the marketplace. This cap is designed to prevent dominant platforms from leveraging advertising spend to crush competition."
    }
}

# DENY: Social media platform non-compliance (content removal obligations)
deny[result] if {
    applicable
    is_large_platform
    input.content.reported.illegal_content == true
    not input.content.moderation.responded_48h == true
    result := {
        "rule": "tr_content_removal_obligation",
        "severity": "high",
        "message": "Large platforms must respond to illegal content reports within 48 hours under Turkish law. Failure to comply with removal orders results in bandwidth throttling and advertising bans.",
        "jurisdiction": "TR",
        "remediation": "Respond to content removal requests within 48 hours. Implement processes to review reported content and comply with valid legal orders. Bandwidth throttling progresses: 50% -> 75% -> 90% for continued non-compliance."
    }
}

# DENY: Social media influencer not registered
deny[result] if {
    applicable
    is_commercial
    input.content.creator.type == "influencer"
    not input.content.creator.tr_registered == true
    result := {
        "rule": "tr_influencer_registration",
        "severity": "medium",
        "message": "Turkey requires social media influencers engaged in commercial activity to register with the Ministry of Commerce. Unregistered commercial activity may result in fines.",
        "jurisdiction": "TR",
        "remediation": "Register as a commercial content creator with the Turkish Ministry of Commerce. Set creator.tr_registered=true after registration. This applies to all influencers regularly posting sponsored content to Turkish audiences."
    }
}
