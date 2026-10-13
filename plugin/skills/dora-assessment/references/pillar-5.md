# Pillar 5: information-sharing arrangements (Article 45)

Read this after SKILL.md, for any question about cyber threat information sharing, sharing communities or arrangements, or notifying the authority of membership. Everything in SKILL.md still applies.

## What there is to assess

Pillar 5 holds one checkable obligation. An entity that joins an information-sharing arrangement must notify its competent authority when its membership is validated. It must notify again once the membership ends and that ending takes effect (DORA Art. 45(3)). Participation itself is voluntary. **Not being a member of any arrangement is never a gap.**

The library holds one document, **`pillar5-regulation`**, and no check document. So:

- every Pillar 5 answer is an **ad-hoc / advisory assessment**, and you say so;
- the CHECKS block is replaced by a single line: `Obligation — Art. 45(3) notification: <state>`;
- severity is graded against the fixed definitions in SKILL.md, naming the definition used. A membership with no notification on record is **Critical**: a regulator-facing obligation that cannot be evidenced at all.

Do not build further checks out of the "qualifying arrangement" text in Article 45. It describes what an arrangement must define. That is a question about the arrangement's rules, not about the entity. If the user asks whether a specific group qualifies, answer from `pillar5-regulation` and state that it depends on that group's own rules, which you have not seen unless they supplied them.

## Evidence modes

`pillar5-regulation`, section "What evidence an assessment needs", states these modes:

| Mode | Source | What it supports |
|---|---|---|
| **A** | A ServiceNow connection to the entity's compliance records, where memberships and notifications are tracked | Each membership, and whether a notification is on record for joining and for leaving |
| **B** | A list or export of the arrangements, with join dates, leave dates and notification dates | The same, for the arrangements listed |
| **C** | A written description | Whether a notification process exists. Whether each notification was actually sent is `not determinable` |

When there is no evidence, the stop message names these sources: a record or list of the sharing arrangements they belong to, with the dates they notified the authority, or a written description of how that is handled.

## What to report

For each membership report four things:

- the arrangement;
- the date membership was validated;
- the date the authority was notified, if any;
- for memberships that ended, the date the ending took effect and the date that was notified.

A notification date later than the validation date is not itself a gap: Article 45(3) sets no deadline. Report it as a fact.
