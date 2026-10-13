# Pillar 4: the Register of Information (Articles 28–30)

Read this after SKILL.md, for any question about the Register of Information, the RoI templates (B_01.01–B_99.01), ICT third-party providers, contractual arrangements or concentration risk. Everything in SKILL.md still applies. This file adds what is specific to Pillar 4.

## Evidence modes

`pillar4-regulation`, section "What evidence an assessment needs", is the library's statement of these modes. This table is the same content, with the detail an assessment needs:

| Mode | Source | What it supports |
|---|---|---|
| **A** | A ServiceNow MCP connector | Every check. The linkage mechanics below apply as written. |
| **B1** | A Register of Information export: the Excel master template, or the plain-CSV reporting package, one sheet or file per template (B_01.01 … B_99.01) | Checks 1, 4 and 5 in full. Check 3 for arrangement references across templates, not junction records. Check 2 is `not determinable`: the register does not carry function-to-service links. |
| **B2** | A CMDB and relationship export (Excel/CSV) | Check 2 where the export carries the function record's reference fields or a relationship table with both endpoints and a relationship type. Check 3 where it carries the contract junction records. Other checks only as far as its columns go. |
| **C** | A written description of how their environment is modelled | Orientation only. Most checks resolve to `not determinable`. |

A file the user supplies may be neither B1 nor B2 cleanly. Classify it by what its sheets and columns actually contain, not by its name, and say which you took it for.

In modes B1 and B2, be explicit about what a flat export cannot do. The linkage mechanics assume a queryable instance. List-type reference fields and junction records have no equivalent in a single sheet unless the export carries them. Where the export does not carry the link a check needs, that check is `not determinable`. Say so in the manifest rather than inferring links from name similarity. Cross-template consistency in a B1 register *is* testable, and is the core of Check 3 there: the same arrangement reference number in B_02.01, B_02.02, B_03.01 and so on.

When there is no evidence, the stop message names these sources: a ServiceNow connector, a Register of Information export (Excel or CSV), a CMDB export, or a written description of how the register is set up.

## Documents to load

- **`pillar4-check`**: the checks. For an assessment it is always loaded, and its checks are the checks you run.
- **`pillar4-regulation`**: the obligations the checks rest on (Articles 28–30). Load it to cite an obligation.
- **`pillar4-fields`**: the RoI templates column by column, the ITS sentinel values, and what ServiceNow import makes mandatory. Load it whenever a check turns on a specific template, column or code value, which most do.
- **`pillar4-servicenow-design`**: how the register is built in ServiceNow: tables, reports, population order. Load it when the evidence comes from ServiceNow (mode A or B).

## What to pull

Pull only what the checks need. That means the register's own records: legal entities, branches, functions, third-party providers, contracts and their junction records, supply chains, and assessments. For Check 2 only, also pull the Business Services and Service Offerings the functions link to.

## Linkage mechanics: Checks 2 and 3 only

Two checks turn on links between records rather than on values in one record. Nothing else in a Pillar 4 assessment requires traversal. So do not traverse further than these two checks need, and do not report chain depth, missing downstream CIs, or continuity-plan links as findings. The library defines no criterion for them.

"CIF" (Critical or Important Function) is the common shorthand for a DORA function record, and the two terms are interchangeable. In the RoI a function is a row of B_06.01 (Functions identification). In the library's check documents it is "a DORA function".

### Check 2: function to its supporting service (hop A)

A function links to its **anchor**: a Business Service, or a Business Process that in turn links to a Business Service. Both anchors are valid. Omitting the Business Process is a modelling choice, not a defect. Report which anchor was used.

**Check the fields before the relationship table.** In E&P's reference deployment the function record carries two **list-type (multi-select)** reference fields, `business_service_list` and `service_offering_list`. The link is *not* a `cmdb_rel_ci` row, so a relationship query alone reads as unreachable when the link is in fact present. This is exactly the failure `pillar4-check` Check 2 describes.

Treat that as a pattern to test for, **not** as a fact about the instance you are connected to. Field names and modelling differ between deployments. Before concluding anything, check all three: the function record's own reference fields, **and** their `_list` variants, **and** the relationship table. If no mechanism is confirmable, the link is `not determinable`. Say which mechanisms you checked.

A function can legitimately relate to more than one Business Service and Service Offering. Name all of them rather than the first match. Surface a function spanning several services as a fact worth knowing (for scoping and concentration), not something to collapse to one.

For a Business Process anchor, the field linking the process to its Business Service is not established, and the library has no CSDM reference material that establishes it. Confirm it on the instance rather than guessing a name.

### Check 3: contracts to entities and providers (junction records)

A contract reaches the entities using and signing it, and the providers delivering it, **through junction records**, not direct references on the contract. Writing or reading an entity identifier directly against a contract field fails silently: no error, no value. Confirm the junction records exist, because a successful-looking save is not evidence. This is what `pillar4-check` Check 3 means by junction records "confirmed to exist".

### For both

- **The mechanisms above are the expected case, not the only valid one.** Before treating a link as absent, check for *any* relationship type or reference field connecting the two records. If a non-standard mechanism carries the link, the link is present (`determined`). Name the mechanism, and note the deviation as a Low-severity hygiene finding.
- Where one provider or service supports more than one function, name the other functions. That is a concentration signal Article 29 cares about.
- State the mechanism you checked for each link, not prose.

## Platform-enforced constraints

Some rules the platform enforces, so stored data cannot violate them. Do not report them as findings:

- Identifier shape validation on legal entity records.
- Mandatory currency where a monetary value is present.
- Coded reference fields. Country and currency are stored as codes and displayed as labels. Assess ISO conformance at the **export layer**, never against the displayed value.

Field codes on platform tables do **not** align positionally with regulatory column codes. Map by meaning, never by code equality.

Some fields are **read-only and derived**. Writing to them succeeds silently without changing the value. Where an expected value is absent, establish whether the field is writable before reporting an omission.

## Sentinel values: read before counting anything as populated

The ITS defines some values that look like real data but mean absence. `pillar4-fields` lists them per column, and `pillar4-check` Check 5 tests for them. Apply them to **every** completeness figure you report, not only when running Check 5.

The same value can mean opposite things on different templates. `9999-12-31` means "still active" on B_01.02 and "indefinite" on a B_02.02 end date. On B_06.01's assessment date and B_07.01's audit date it means "not done". So resolve each value against its own column, never uniformly. In any completeness figure, report sentinel values separately from real values.

## Building a register

Where no Register of Information, function register or contract records exist, name the exact template, column and ServiceNow object where each item belongs, based on `pillar4-fields` and `pillar4-servicenow-design`. Follow the population order in `pillar4-servicenow-design`, because each step references the ones before it.
