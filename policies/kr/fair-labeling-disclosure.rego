# South Korea Fair Labeling and Advertising Act - Disclosure Requirements
# Law: Fair Labeling and Advertising Act (공정거래법)
# Regulator: Korea Fair Trade Commission (KFTC)
# Effective: 2020-09-01 (influencer guidelines), updated 2023
# Source: https://www.ftc.go.kr/
# Additional: Night-time push notification ban (Information and Communications Network Act)

package m3m3tic.policy.kr.fair_labeling_disclosure

import rego.v1

# Applicable when South Korea is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "KR"
}

# ONLY accepted disclosure label in Korea - English alternatives are NOT valid
accepted_labels := {"광고"}

# Check for valid Korean disclosure
has_valid_disclosure if {
    some label in input.content.disclosure.labels
    label in accepted_labels
}

# Check if content is a push notification
is_push_notification if {
    input.content.delivery.channel == "push_notification"
}

is_push_notification if {
    input.content.delivery.type == "push"
}

# Check if delivery time falls in restricted night hours (21:00-08:00 KST)
is_nighttime if {
    hour := input.content.delivery.local_hour_kst
    hour >= 21
}

is_nighttime if {
    hour := input.content.delivery.local_hour_kst
    hour < 8
}

# Check if content is commercial/sponsored
is_commercial if {
    input.content.compensation.model != "unpaid"
    input.content.compensation.model != "none"
    input.content.compensation.model != null
}

is_commercial if {
    input.content.is_advertisement == true
}

# DENY: Commercial content without "광고" label
deny[result] if {
    applicable
    is_commercial
    not has_valid_disclosure
    result := {
        "rule": "kr_disclosure_label_required",
        "severity": "critical",
        "message": "Korean law requires the exact label '광고' for all commercial content. English alternatives (#ad, #sponsored) are NOT accepted by KFTC. The label must appear at the BEGINNING of the content.",
        "jurisdiction": "KR",
        "remediation": "Add '광고' at the beginning of the content or title. Do not use English equivalents. The label must be visible without user interaction (no 'see more' gates)."
    }
}

# DENY: Has disclosure but using wrong format (English labels)
deny[result] if {
    applicable
    is_commercial
    some label in input.content.disclosure.labels
    not label in accepted_labels
    not has_valid_disclosure
    result := {
        "rule": "kr_disclosure_wrong_format",
        "severity": "critical",
        "message": sprintf("Disclosure label '%s' is not accepted in Korea. Only '광고' is recognized by KFTC. International labels like #ad or #sponsored have no legal standing.", [label]),
        "jurisdiction": "KR",
        "remediation": "Replace all disclosure labels with '광고' for Korean audiences. This is a strict requirement with no alternatives."
    }
}

# DENY: Push notification during night-time hours (21:00-08:00 KST)
deny[result] if {
    applicable
    is_push_notification
    is_nighttime
    result := {
        "rule": "kr_nighttime_push_ban",
        "severity": "high",
        "message": "Push notifications to Korean users are prohibited between 21:00 and 08:00 KST under the Information and Communications Network Act. This applies to ALL push notifications, not just commercial ones.",
        "jurisdiction": "KR",
        "remediation": "Reschedule push notification delivery to between 08:00 and 21:00 KST (Asia/Seoul timezone). Implement timezone-aware scheduling for Korean audience segments."
    }
}

# DENY: AI-generated content without AI disclosure (AI Basic Act Jan 2026)
deny[result] if {
    applicable
    input.content.identity.type == "ai_agent"
    not input.content.ai_disclosure.labeled == true
    result := {
        "rule": "kr_ai_content_label",
        "severity": "high",
        "message": "AI-generated content targeting Korean audiences must be labeled per the AI Basic Act (effective January 2026). Both machine-readable and human-readable disclosure required.",
        "jurisdiction": "KR",
        "remediation": "Add AI content disclosure label visible to end users. Include both machine-readable metadata (ai_disclosure.labeled=true) and human-visible indicator."
    }
}
