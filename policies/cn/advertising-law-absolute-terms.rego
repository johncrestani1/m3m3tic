# People's Republic of China - Advertising Law (2015 Revision) - Absolute/Superlative Terms
# Version: 2024.0
# Effective: 2015-09-01 (2015 revision), enforced ongoing
# Source: http://www.npc.gov.cn/npc/c10134/201504/89515e429c0e4f8ebd4b04e98e685f19.shtml
#
# Article 9(3) prohibits the use of superlatives and absolute terms in advertising,
# including "best", "most", "first", "number one", etc. Violations carry fines
# of 200,000-1,000,000 RMB. This applies to all advertising content targeting
# audiences in mainland China.

package m3m3tic.policy.cn.advertising_law_absolute_terms

import data.m3m3tic.policy.interface as iface

# Self-selection: applies when CN is in audience geos
applicable {
	iface.geo_applicable(input.content.audience.geos, "CN")
}

# Banned absolute terms (Chinese)
banned_terms_zh := [
	"最好", "最佳", "最优", "最大", "最强", "最高",
	"第一", "唯一", "首个", "首选", "独家",
	"顶级", "极品", "绝对", "万能", "全网最低",
	"国家级", "世界级", "全球首发",
	"史无前例", "前所未有", "永久",
	"100%", "零风险", "无副作用",
]

# Banned absolute terms (English equivalents often used in CN-targeted ads)
banned_terms_en := [
	"best", "most", "number one", "no.1", "#1",
	"first ever", "only one", "exclusive first",
	"top-level", "supreme", "absolute",
	"universal", "lowest price", "guaranteed lowest",
	"national-level", "world-class", "global first",
	"unprecedented", "permanent", "forever",
	"100%", "zero risk", "no side effects",
]

# Deny: content contains banned Chinese superlative terms
deny[result] {
	applicable
	text := iface.all_text(input)
	term := banned_terms_zh[_]
	contains(text, term)
	result := iface.make_result(
		"cn-adlaw-absolute-zh-001",
		"block",
		sprintf("PRC Advertising Law Article 9(3): Prohibited absolute/superlative term detected: '%s'. Fines range 200,000-1,000,000 RMB.", [term]),
		"CN",
		sprintf("Remove or replace the term '%s' with qualified language (e.g., 'among the leading', 'high quality'). Absolute claims are strictly prohibited.", [term]),
	)
}

# Deny: content contains banned English superlative terms targeting CN
deny[result] {
	applicable
	text := iface.all_text(input)
	term := banned_terms_en[_]
	contains(lower(text), lower(term))
	result := iface.make_result(
		"cn-adlaw-absolute-en-002",
		"block",
		sprintf("PRC Advertising Law Article 9(3): Prohibited absolute/superlative term detected (English): '%s'. Law applies regardless of language used.", [term]),
		"CN",
		sprintf("Remove or replace '%s' with qualified language. Even English-language ads targeting China must comply with Article 9(3).", [term]),
	)
}

# Warn: comparative claims require substantiation (Article 13)
deny[result] {
	applicable
	claim := input.content.claims[_]
	claim.type == "comparative"
	count(claim.evidence) == 0
	result := iface.make_result(
		"cn-adlaw-comparative-003",
		"warn",
		"PRC Advertising Law Article 13: Comparative advertising claims must be based on objective, verifiable data.",
		"CN",
		"Attach third-party test reports or government-recognized certification to substantiate comparative claims.",
	)
}
