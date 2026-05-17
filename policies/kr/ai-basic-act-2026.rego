# South Korea AI Basic Act 2026 - AI Content Labeling
# Law: AI Basic Act (인공지능 기본법)
# Effective: 2026-01-01
# Regulator: Korea Communications Commission (KCC) / Ministry of Science and ICT
# Source: https://www.law.go.kr/ (AI 기본법)
# Scope: All AI-generated content distributed to Korean audiences

package m3m3tic.policy.kr.ai_basic_act_2026

import rego.v1

# Applicable when South Korea is in audience geos
applicable if {
    some geo in input.content.audience.geos
    geo == "KR"
}

# Check if content is AI-generated
is_ai_generated if {
    input.content.identity.type == "ai_agent"
}

is_ai_generated if {
    input.content.generation_method == "ai"
}

is_ai_generated if {
    input.content.ai_disclosure.is_ai_generated == true
}

# Check if content is deepfake
is_deepfake if {
    input.content.media_type == "deepfake"
}

is_deepfake if {
    input.content.ai_disclosure.is_deepfake == true
}

is_deepfake if {
    input.content.ai_disclosure.face_swap == true
}

is_deepfake if {
    input.content.ai_disclosure.voice_synthesis == true
}

# Check for machine-readable AI label
has_machine_readable_label if {
    input.content.ai_disclosure.machine_readable == true
}

has_machine_readable_label if {
    input.content.metadata.ai_generated_flag == true
}

# Check for human-readable AI label
has_human_readable_label if {
    input.content.ai_disclosure.human_visible_label == true
}

has_human_readable_label if {
    input.content.ai_disclosure.labeled == true
}

# Check for visible deepfake label
has_visible_deepfake_label if {
    input.content.ai_disclosure.deepfake_label_visible == true
}

# Check if one-time human notice was provided (for machine-only labeling)
has_onetime_human_notice if {
    input.content.ai_disclosure.onetime_notice_delivered == true
}

# DENY: AI-generated content without any labeling
deny[result] if {
    applicable
    is_ai_generated
    not has_machine_readable_label
    not has_human_readable_label
    result := {
        "rule": "kr_ai_act_content_label_missing",
        "severity": "critical",
        "message": "AI-generated content must be labeled under the AI Basic Act (effective Jan 2026). Neither machine-readable nor human-readable labels detected.",
        "jurisdiction": "KR",
        "remediation": "Add AI content label. Options: (1) Human-readable visible label in content, (2) Machine-readable metadata flag WITH one-time human notice to viewers that AI content may appear. At minimum, set ai_disclosure.machine_readable=true and provide one-time notice."
    }
}

# DENY: Machine-readable only without one-time human notice
deny[result] if {
    applicable
    is_ai_generated
    has_machine_readable_label
    not has_human_readable_label
    not has_onetime_human_notice
    result := {
        "rule": "kr_ai_act_notice_required",
        "severity": "medium",
        "message": "Machine-readable AI labeling is present but no human-readable label exists. When using machine-only labeling, a one-time human notice must be delivered to inform users that AI-generated content may appear.",
        "jurisdiction": "KR",
        "remediation": "Either add a human-visible AI label to the content, or ensure the platform has delivered a one-time notice to users explaining that AI-generated content exists and is machine-labeled. Set ai_disclosure.onetime_notice_delivered=true after notice delivery."
    }
}

# DENY: Deepfake content without visible label
deny[result] if {
    applicable
    is_deepfake
    not has_visible_deepfake_label
    result := {
        "rule": "kr_ai_act_deepfake_label",
        "severity": "critical",
        "message": "Deepfake content (face swap, voice synthesis, or likeness manipulation) MUST have a VISIBLE label. Machine-only labeling is NOT sufficient for deepfakes under the AI Basic Act.",
        "jurisdiction": "KR",
        "remediation": "Add a clearly visible on-screen label indicating the content contains AI-generated deepfake elements. The label must be persistent (not dismissable) and readable without interaction. Set ai_disclosure.deepfake_label_visible=true."
    }
}

# DENY: Deepfake political content (absolute ban during elections)
deny[result] if {
    applicable
    is_deepfake
    input.content.category == "political"
    input.content.context.election_period == true
    result := {
        "rule": "kr_ai_act_deepfake_political_ban",
        "severity": "critical",
        "message": "Deepfake political content is BANNED during election periods under the AI Basic Act and Public Official Election Act. No labeling can remediate this - the content must not be published.",
        "jurisdiction": "KR",
        "remediation": "Do not publish deepfake political content during Korean election periods. This is an absolute prohibition with no exception. Remove or delay publication until after the election period concludes."
    }
}
