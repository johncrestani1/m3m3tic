# Tests for FTC Endorsement Guides policy (ftc-endorsement-2024.1)
package m3m3tic.policy.us.ftc_endorsement_test

import data.m3m3tic.policy.us.ftc_endorsement as policy

# Test 1: Compensated actor with no disclosure targeting US audience -> deny
test_compensated_no_disclosure {
	count(policy.deny) > 0 with input as {
		"relationship": {
			"compensation": {
				"model": "flat_fee",
			},
		},
		"content": {
			"audience": {
				"geos": ["US"],
			},
			"disclosures_attached": [],
			"claims": [],
		},
	}
}

# Test 2: Compensated actor with sponsorship disclosure targeting US audience -> allow
test_compensated_with_disclosure {
	count(policy.deny) == 0 with input as {
		"relationship": {
			"compensation": {
				"model": "flat_fee",
			},
		},
		"content": {
			"audience": {
				"geos": ["US"],
			},
			"disclosures_attached": [
				{
					"type": "sponsorship",
					"method": "platform_native",
				},
			],
			"claims": [],
		},
	}
}

# Test 3: Non-US audience (DE) -> policy not applicable, no deny
test_non_us_audience_not_applicable {
	count(policy.deny) == 0 with input as {
		"relationship": {
			"compensation": {
				"model": "flat_fee",
			},
		},
		"content": {
			"audience": {
				"geos": ["DE"],
			},
			"disclosures_attached": [],
			"claims": [],
		},
	}
}
