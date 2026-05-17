# ADR-010: Live Content as First-Class Content Mode

## Status
Accepted

## Context
Live video (Instagram Live, TikTok Live, YouTube Live) has fundamentally different compliance characteristics than static/recorded content:
- Cannot be pre-approved (happening in real-time)
- Disclosures must be verbal (can't reliably add text overlays mid-stream)
- Mistakes cannot be edited post-hoc
- Some jurisdictions have specific live-stream disclosure rules (Korea KFTC guidelines)
- Higher compliance risk due to spontaneity
- Audience size fluctuates in real-time

We considered treating live as just another format. Rejected because the evaluation logic differs: you can't BLOCK a live stream the same way you block a post. You can only WARN before it starts and AUDIT after.

## Decision
`content.medium.mode` is a first-class field: `static | recorded | live`. When mode == "live":
- Pre-stream evaluation produces WARNINGS (not blocks) for disclosure requirements
- Verbal disclosure plan is checked (not actual text presence)
- Post-stream audit trail is required
- Platforms with live-specific APIs (Instagram Live, TikTok Live) get mode-aware renderings
- `content.live_metadata` carries: started_at, duration, audience_size_realtime

## Consequences
- Policy packs can write mode-specific rules: `input.content.medium.mode == "live"`
- Evaluation for live content is pre-emptive (before stream starts) + retrospective (after)
- Authority.live_video boolean controls whether an actor CAN go live at all
- The value "conditional" means live requires per-instance approval
