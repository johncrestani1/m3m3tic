# Japan Stealth Marketing Designation 2023
# Law: Act against Unjustifiable Premiums and Misleading Representations
# Designation: "Designation of Difficult-to-Identify Advertisements" (Stealth Marketing)
# Effective: 2023-10-01
# Source: https://www.caa.go.jp/policies/policy/representation/fair_labeling/stealth_marketing/
# Regulator: Consumer Affairs Agency (CAA)
# Liability: Advertiser (not influencer/endorser)

package m3m3tic.policy.jp.stealth_marketing_2023

import rego.v1

# Applicable when Japan is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "JP"
}

# Accepted disclosure labels for Japan
accepted_labels := {"広告", "PR", "プロモーション", "宣伝"}

# Compensation models that trigger disclosure requirement
# "unpaid" is the ONLY model that does NOT trigger
compensated_models := {"flat_fee", "cpm", "cpc", "cpa", "gifted", "affiliate", "experience", "commission", "barter", "equity"}

# Check if content has valid Japanese disclosure
has_valid_disclosure if {
    some label in input.content.disclosure.labels
    label in accepted_labels
}

# Check if actor is compensated (any model except unpaid)
is_compensated if {
    input.content.compensation.model in compensated_models
}

is_compensated if {
    input.content.compensation.model != "unpaid"
    input.content.compensation.model != "none"
    input.content.compensation.model != null
}

# DENY: Compensated content without proper Japanese disclosure
deny[result] if {
    applicable
    is_compensated
    not has_valid_disclosure
    result := {
        "rule": "jp_stealth_marketing_disclosure",
        "severity": "high",
        "message": "Compensated content targeting Japan must include visible disclosure using accepted Japanese labels: 広告, PR, プロモーション, or 宣伝. The advertiser bears legal liability under the Stealth Marketing Designation (Oct 2023).",
        "jurisdiction": "JP",
        "remediation": "Add one of the following labels prominently in the content: 広告, PR, プロモーション, 宣伝. Label must be clearly recognizable by general consumers without requiring additional action to discover."
    }
}

# DENY: Disclosure exists but is not in accepted Japanese format
deny[result] if {
    applicable
    is_compensated
    count(input.content.disclosure.labels) > 0
    not has_valid_disclosure
    result := {
        "rule": "jp_stealth_marketing_label_format",
        "severity": "medium",
        "message": "Content has disclosure labels but none match accepted Japanese formats. English labels like '#ad' or '#sponsored' are NOT sufficient for Japanese audiences.",
        "jurisdiction": "JP",
        "remediation": "Replace or supplement existing disclosure labels with one of: 広告, PR, プロモーション, 宣伝. The label must be in Japanese for Japanese-targeted content."
    }
}

# DENY: Affiliate links without disclosure
deny[result] if {
    applicable
    input.content.contains_affiliate_links == true
    not has_valid_disclosure
    result := {
        "rule": "jp_stealth_marketing_affiliate",
        "severity": "high",
        "message": "Content containing affiliate links targeting Japan must include disclosure. Affiliate compensation constitutes a material connection under the Stealth Marketing Designation.",
        "jurisdiction": "JP",
        "remediation": "Add prominent disclosure label (広告, PR, プロモーション, or 宣伝) when content includes affiliate links for Japanese audiences."
    }
}
