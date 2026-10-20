# Changelog

Client-visible changes, newest first.

## 5.3.2

- The short first reply is now under 180 words (was 250).
- Each problem is two short sentences at most: what is wrong, naming the record in its own
  words and dates, then what to do, starting "The regulation requires" or "We recommend".
  This replaces the separate "The regulation requires this." / "We recommend this." label.
- The pattern line and the "one thing that's fine" line are one sentence each.

## 5.3.1

- The short first reply follows a fixed layout: "I checked 22 functions. 8 have problems.",
  then "The three worth fixing first", "One thing across the whole register", "One thing
  that's fine", and "Want the other five, or more detail on any of these?"
- Each problem names the record and uses its own words and dates, and ends with "The
  regulation requires this." or "We recommend this." Severity labels and article numbers
  move to the full report; severity still decides the order.
- The opening line mentions checks that could not be tested only when there are any. A
  likely cause in the pattern line is marked as one ("It looks like …").

## 5.3.0

- An open question ("check our register", "assess us against DORA") now gets a short first
  reply of at most 250 words, in plain words. It names what was checked and how many
  checks the source could test, then the three biggest problems, one pattern across the
  data and one thing that works, and offers the full report. The full report is unchanged
  and follows when you ask for it. Every check still runs; only the first reply is shorter.
- Problems are ranked by severity, then by how many records they affect, so the same data
  always gives the same three.
- Each problem says either "the regulation requires" or "we recommend", so law and E&P
  advice stay apart.

## 5.2.4

- The skill no longer names a specific ERP system for the optional document library: it
  holds "sales or financial data" and company registration / LEI information. No change
  to the checks.
- First release from the public repository `Einar-Partners/dora-assessment`.

## 5.2.3

- The Claude connector is renamed from `knowledge-base` to `dora-knowledge-base`, so it
  reads as the DORA library next to other connectors. Same URL, same tools. Claude stores
  the sign-in per connector name, so sign in once more after updating. The Vibe connector
  keeps its name `knowledge_base`.
- New ChatGPT package, `dora-assessment-<version>-chatgpt.zip`. The checks are the same;
  sign-in is browser-only, because ChatGPT accepts no API-key header.

## 5.2.2

- The Knowledge Base moves to `https://uplink.einar.partners/dora/mcp`. Earlier versions
  can no longer reach it. Update, then sign in again: the browser sign-in is tied to the
  old address. API keys keep working.
- Re-running the Vibe installer now points an existing connector at the new address.

## 5.2.1

- Marketplace installs carry only the plugin (`plugin/`), not the whole repository.
  Existing installs replace their cached copy on update.

## 5.2.0

- New Mistral Vibe distribution: an installer for the Vibe CLI (Windows, macOS, Linux),
  a connector snippet, and steps for the Vibe web app. In the CLI, a gate hook blocks
  Knowledge Base tools until the skill is loaded.
- Written descriptions (mode C): a check that needs data stays `not determinable`;
  described facts are reported as orientation, ungraded.
- Only references that appear in a retrieved document may be cited, and the tally line
  is recounted before sending.

## 5.1.0

- Covers Pillar 1 (ICT risk management framework) and Pillar 3 (resilience testing and
  TLPT). With 5.0.0, all five pillars are covered; only the oversight of critical ICT
  providers (Art. 31–44) is out of scope.
- A finding that Pillar 4 Check 2 and Pillar 1 Check 5 share is reported once, under
  Pillar 4.
- Pillar 3 establishes whether TLPT applies before running the TLPT checks.

## 5.0.0

- Covers Pillar 2 (incident management, classification and reporting) and Pillar 5
  (information sharing) alongside Pillar 4.
- The scope comes from the Knowledge Base library, so a pillar added there is picked up
  without a plugin update.
- One verdict and checks block per pillar in multi-pillar answers.
