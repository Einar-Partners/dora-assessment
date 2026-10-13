# Pillar 3: digital operational resilience testing and TLPT (Articles 24–27)

Read this after SKILL.md, for any question about the testing programme, test types, annual testing of systems supporting critical or important functions, threat-led penetration testing (TLPT), TLPT scope, testers and threat intelligence providers, or scenario analysis in ServiceNow. Everything in SKILL.md still applies. This file adds what is specific to Pillar 3.

You assess the *evidence* of testing. You never perform, plan or scope a test yourself, and you never judge whether a test itself was technically adequate.

## First: does TLPT apply at all?

TLPT applies only to entities their competent authority identifies (DORA Art. 26). RTS (EU) 2025/1190 Art. 2(2) lists the entity types that must perform it by default, unless the authority decides otherwise; `pillar3-regulation` gives the list. Before running Checks 3 or 4, establish whether the entity is required to perform TLPT: from the evidence, from the user, or from the Art. 2(2) criteria where the evidence shows them. If it is not required, Checks 3 and 4 are `not determinable` with that reason, never a gap. If you cannot establish it, say so under Limitations. Checks 1 and 2 (Art. 24) apply to every entity except microenterprises.

## Evidence modes

`pillar3-regulation`, section "What evidence an assessment needs", states these modes:

| Mode | Source | What it supports |
|---|---|---|
| **A** | A ServiceNow connection to Operational Resilience Management (scenario analysis), plus tester and programme records | Every check in `pillar3-check` |
| **B** | An export of test or scenario records and tester credentials (Excel/CSV) | Checks 1, 2 and 4 as far as the export's columns go. Check 3 only if it includes CI or relationship data |
| **C** | A written description of the testing programme | Orientation only. Every check resolves to `not determinable` |

When there is no evidence, the stop message names these sources: a ServiceNow connection to Operational Resilience Management, an export of test records and tester details, or a written description of the testing programme.

## Documents to load

- **`pillar3-check`**: the four checks. Always loaded for an assessment.
- **`pillar3-regulation`**: Articles 24–27 and the TLPT RTS (EU) 2025/1190, including the default-scope list and the tester rules. Load it to cite an obligation.
- **`pillar3-fields`**: the scenario analysis record as ServiceNow holds it (`[PLATFORM]`), and E&P's recommended records for other test types, testers and TLPT scope (`[E&P]`). Load it for Checks 1 and 4.
- **`pillar3-servicenow-design`**: where testing lives in ServiceNow, and the TLPT scope as a chain traversal. Load it for Check 3 and whenever the evidence comes from ServiceNow.

`pillar3-fields` marks its record lists for test types other than scenario analysis as "E&P recommendation, not verified". Never report a record missing one of those attributes as a regulatory gap.

## Check-specific rules

**Check 1: scenario analysis data.** This check rests on ServiceNow's scenario analysis Summary panel (`[PLATFORM]`). Where the evidence is not from ServiceNow and carries no equivalent impact-tolerance fields, the check is `not determinable`, and you say it is platform-specific. An impact tolerance of `0` on several services reads as an unset default, not as a genuine "any disruption is a breach" assessment. Report it as a data-credibility signal, not as proof.

**Check 2: annual coverage (DORA Art. 24(6)).** You need two things: the list of ICT systems and applications supporting critical or important functions, and the test records per system for the last 12 months. The system list comes from the function chain (Pillar 1 Check 5, or Pillar 4 evidence). If you cannot establish which systems support critical functions, coverage is `not determinable`. A current, approved programme document is never evidence of coverage on its own. Check the programme and the per-system records separately.

**Check 3: TLPT scope (traversal).** The scope is rebuilt by traversing from the covered functions down the same CSDM chain as Pillar 1 Check 5. Use the hop mechanics in `references/pillar-1.md`: the `_list` fields at hop A and the reverse reference at hop C. Where the chain reaches a Service Instance backed by a third-party provider, that provider and its contract belong in scope: pull them from the Pillar 4 register evidence, not from a separate list. The "good" answer includes the date the competent authority validated the scope. A scope with no validation date is a finding under this check.

**Check 4: testers.** Check each rule separately:

- internal testers need the authority's approval (Art. 27(2)(a));
- external testers are needed every three tests (Art. 26(8));
- a significant credit institution uses external testers only (Art. 26(8));
- the threat intelligence provider is external in **every** TLPT, including an intra-group ICT provider (RTS (EU) 2025/1190 Art. 1(10)).

A single "internal/external" field satisfies none of these on its own. Name which rule each piece of evidence does or does not show.

## Cross-pillar

Pillar 3 depends on the other pillars' evidence. The critical functions and their systems come from Pillar 1 or Pillar 4. Third-party participation in TLPT comes from the Pillar 4 register: CIF contracts need a TLPT participation clause (Art. 30). Where that evidence is present, reuse it, saying so under Linkage. Where it is absent, the dependent part of Checks 2 and 3 is `not determinable`.
