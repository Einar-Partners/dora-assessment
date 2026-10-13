# Pillar 1: the ICT risk management framework (Articles 5–16)

Read this after SKILL.md, for any question about ICT risk governance, the ICT risk management framework, the identification of functions and assets (Article 8), ICT asset inventories, protection and detection, business continuity and recovery plans, backups, RTO/RPO, or CSDM modelling of critical or important functions. Everything in SKILL.md still applies. This file adds what is specific to Pillar 1.

## First: does the full framework apply?

Article 16 exempts some entities from Articles 5–15: small and non-interconnected investment firms, certain exempted payment and e-money institutions, certain exempted credit institutions, and small occupational retirement institutions. They follow a simplified framework instead.

Establish the entity type from the evidence or ask for it. If the entity may fall under Article 16, say so before assessing, and do not report Articles 5–15 obligations as gaps for it. `pillar1-regulation` covers the simplified framework only in outline. A detailed Article 16 question is not covered by any check, so run it as ad-hoc.

## Evidence modes

`pillar1-regulation`, section "What evidence an assessment needs", states these modes:

| Mode | Source | What it supports |
|---|---|---|
| **A** | A ServiceNow connection to the CMDB/CSDM: function records, CIs, information-asset records | Every check in `pillar1-check` |
| **B** | A CMDB or asset-inventory export (Excel/CSV): functions, ICT and information assets, recovery objectives | Checks 1, 2, 3, 4, 6 and 7 as far as the export's columns go. Check 5 only if it includes a relationship or dependency table |
| **C** | A written description of the ICT risk management framework | Orientation only. Every check resolves to `not determinable` |

For Check 3, an export can show a periodic review date, but it rarely shows whether an update followed a specific major change. Say which half you could test.

When there is no evidence, the stop message names these sources: a ServiceNow connection to the CMDB, a CMDB or asset-inventory export, or a written description of the ICT risk management framework.

## Documents to load

- **`pillar1-check`**: the seven checks. Always loaded for an assessment.
- **`pillar1-regulation`**: Articles 5–16, including the 2-hour recovery ceilings of RTS (EU) 2024/1774 Art. 24 and which entity types they apply to. Load it to cite an obligation.
- **`pillar1-fields`**: the nine mandatory ICT asset fields (RTS (EU) 2024/1774 Art. 4(2)(b)), E&P's information-asset attributes, the three levels of recovery objective, and the function-naming signals. Load it for Checks 1, 2, 4 and 6.
- **`pillar1-servicenow-design`**: the CSDM object model and the evidence chain hop by hop. Load it for Check 5 and whenever the evidence comes from ServiceNow.

Keep the confidence levels in `pillar1-fields` visible. Its information-asset attributes and naming signals are `[E&P]` recommendations, not DORA requirements: never report a shortfall against them as a regulatory gap. Use `determined (advisory)` or a Low/Medium house-standard finding, as the check says.

## Check-specific rules

**Check 4: recovery objectives at three levels.** Function (DORA Art. 12(6)), ICT asset (RTS 2024/1774 Art. 4(2)(b)(vi)) and policy are separate records. Test each on its own. A present function-level objective never covers a blank asset-level one. Apply a 2-hour ceiling only to a CCP, a CSD or a trading venue, and only once the entity type is confirmed. Recovery objectives are in whole hours: `0` means not defined, and `1` means under an hour (see `references/pillar-4.md`, Sentinel values, for the register side).

**Check 5: the evidence chain (traversal).** Follow the hop table in `pillar1-servicenow-design`. Each hop uses a different mechanism:

- **Hop A** (function → anchor): check the single-value field **and** its `_list` variant. This is the same link as Pillar 4 Check 2. Use the mechanics in `references/pillar-4.md`, and report it once (SKILL.md, Output contract).
- **Hop C** (Business Service → Offering) is a **reverse reference**: the field sits on the Offering and points up. A relationship query alone returns nothing. Reporting a break without the reverse query is a false finding.
- **Hop F** (Service Instance → Business Application) runs **upward**. This is where the continuity plan is located.
- **Hop G** (→ contract, provider, entity) uses junction tables, with the same silent-failure risk as Pillar 4 Check 3.

Report which anchor the function uses (Business Process, Business Capability or Business Service). A shorter chain from a Business Service anchor is a modelling choice, not a shortfall. Check 5 is deliberately loose: it asks whether a path exists, not whether every hop is textbook-clean. It is High only where no path exists at all. Apply the Enumeration rule in SKILL.md to every hop before calling it absent. Do not traverse the governance layer (Technical Management Service, Dynamic CI Groups): it is not part of the evidence chain.

**Check 7: non-production evidence only.** Run it only when the evidence is a demo, test or training instance, or the user says it is. On production evidence, show it in the CHECKS block as `Check 7 — not applicable (production evidence)`, and leave it out of the tallies. It is never `not determinable` for that reason, and never a gap.

## Cross-pillar

The same function records and CSDM chain serve Pillar 3's TLPT scope (Check 3) and Pillar 4's register (Checks 2 and 3). Where evidence for several pillars is present, traverse once and reuse the result, saying so under Linkage.
