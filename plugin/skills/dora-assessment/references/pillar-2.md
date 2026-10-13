# Pillar 2: ICT-related incident management, classification and reporting (Articles 17–23)

Read this after SKILL.md, for any question about incident management, major-incident classification, the reporting deadlines, the incident report template, significant cyber threats, or ServiceNow Digital Resilience Incident Reporting. Everything in SKILL.md still applies. This file adds what is specific to Pillar 2.

## Evidence modes

`pillar2-regulation`, section "What evidence an assessment needs", states these modes. The detail an assessment needs:

| Mode | Source | What it supports |
|---|---|---|
| **A** | A ServiceNow MCP connector reaching Incident Management, Security Incident Response, Digital Resilience Incident Reporting (`sn_dri_inc_rptg`) and the CMDB | All three checks in `pillar2-check`. It includes incidents that were never reported, and the CI-to-function gate. |
| **B** | An export of incidents and their DRI assessments, or the submitted reports themselves (the Excel or Word exports of the initial, intermediate and final assessments) | Check 1 and Check 3 for the incidents it covers. Check 2 only for incidents that were reported: an export of reported incidents cannot show a near-miss that never reached assessment. |
| **C** | A written description of the incident process | Orientation only. Every check resolves to `not determinable`. |

Classify a supplied file by what it actually contains. A single submitted report tests Check 1 for that report only. Check 3 needs every report for the same incident.

When there is no evidence, the stop message names these sources: a ServiceNow connector, an export of incidents or the submitted incident reports, or a written description of the incident process.

## Documents to load

- **`pillar2-check`**: the three checks. Always loaded for an assessment.
- **`pillar2-regulation`**: Articles 17–23, the classification test and thresholds (RTS (EU) 2024/1772), and the deadlines (RTS (EU) 2025/301). Load it for any check, because every check turns on a threshold or a clock.
- **`pillar2-fields`**: the report template, field by field (ITS (EU) 2025/302 Annex I). Load it when a check turns on a specific field, such as 2.2 and 2.3 (the two clocks) or the actual-versus-estimate flags.
- **`pillar2-servicenow-design`**: the modules, candidate generation, the assessment questionnaire and the reporting workflow. Load it when the evidence comes from ServiceNow.

The library covers Annex I (major incidents) only. A question on the Annex III cyber-threat notification fields is not covered by any document. Say so, and do not reconstruct the fields from general knowledge.

## What to pull

Pull only what the checks need:

- For each incident in scope: the incident record, and the Digital Resilience Incident it was promoted to, if any.
- Its detection, classification and submission timestamps.
- Each report's assessment answers.
- For Check 2 only: the affected CIs, and the population of incidents that were *not* promoted over the same period. Scope that population by date range and by priority or CI; do not pull every incident.

Ask for the period to assess if the user has not given one.

## Mechanics

### Check 1: the clocks

Two timestamps start the initial-notification clocks: detection (field 2.2) and classification as major (2.3). The notification is due at whichever runs out first: 4 hours from classification, or 24 hours from awareness. There is one exception, in RTS (EU) 2025/301 Art. 5(2). An incident classified as major more than 24 hours after awareness gets 4 hours from classification. Treat that as on time for Check 1. Then raise the late classification under Check 2, where it belongs.

The intermediate report is due 72 hours after the initial notification, even if nothing changed. The final report is due one month after the latest intermediate report. Whether weekend and holiday deadlines move depends on the entity type, under RTS (EU) 2025/301 Art. 5(4)–(6). Establish the entity type from the evidence (or from the Register of Information, where Pillar 4 evidence is present) before applying the extension. If you cannot, that deadline is `not determinable` for weekend cases.

A missed deadline is not a gap if the authority was told by that deadline, with reasons (Art. 5(3)). Look for that record before reporting a gap.

### Check 2: classification and the gate (upward traversal)

This is the one Pillar 2 check that traverses. It is the exception to SKILL.md's rule that traversal serves only the checks that need it: here the check needs it. The gate asks whether an affected CI traces **up** to a critical or important function. That is the reverse direction of Pillar 4's function-to-service link, over the same model. Go from the affected CI up to its Business Service or Service Offering, then to the DORA function that lists it. Use the same mechanisms `references/pillar-4.md` describes for Check 2 there: reference fields, their `_list` variants, and the relationship table. Apply the Enumeration rule in SKILL.md before calling a link absent.

The gate has three tests (RTS (EU) 2024/1772 Art. 6). Any one opens it:

- a critical or important function is affected;
- a financial service that requires authorisation is affected;
- there was successful malicious unauthorised access.

The major test (Art. 8) comes after the gate: either malicious access that may cause data loss, or two or more of the *other* thresholds (Art. 9). Recurring incidents can combine (Art. 8(2)).

Report the classification as traceable only where the recorded decision names the thresholds or gate test it rests on.

### Platform facts: context, not findings

These `[PLATFORM]` facts from `pillar2-servicenow-design` explain evidence. Do not report any of them as a finding on its own:

- The Digital Resilience Incident Flow is **disabled by default**. If no incident has ever been promoted, check this before concluding that nothing qualified. It explains an empty DRI table; it is not itself a regulatory gap.
- The out-of-box candidate trigger (Priority/Urgency, or open more than 24 hours and In Progress) is a convenience filter, not the RTS gate. An incident that met the RTS criteria but not the trigger is a Check 2 finding. The trigger itself is not.
- ServiceNow's documented questionnaire logic does not show the third gate test (an affected authorised financial service). Where you can read the questionnaire, check it. Where you cannot, name it under Limitations. Don't assume either way.

### Check 3: estimates versus actuals

Estimates are allowed in the initial and intermediate reports; the final report requires actuals. The check turns on whether the earlier values are still visible next to the final ones. A single field overwritten across stages is the "bad" answer. Name the fields concerned, using the numbering in `pillar2-fields`.

## Cross-pillar

The report's entity identity (fields 1.4–1.6, including the LEI) is the same identifier the Pillar 4 register carries. Where both kinds of evidence are present, a mismatch is a cross-source consistency finding.
