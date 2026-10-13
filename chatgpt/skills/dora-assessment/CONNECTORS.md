# Connectors

This plugin bundles one connector: the E&P Knowledge Base. That is the only thing it
needs to declare, because it is the only system E&P operates on your behalf.

| Connector name (in `mcp.json`) | Endpoint | Used for |
|---|---|---|
| `dora-knowledge-base` | `https://uplink.einar.partners/dora/mcp` | The DORA library, organised by pillar (currently all five pillars: checks, regulation, field references, ServiceNow design), loaded with `get_document` — the skill's sole source of assessment criteria |

## Authorising it

**Installing the plugin declares this server. It does not sign you in.** The first time
the skill uses it, ChatGPT starts an authorisation flow: a browser window opens and asks
for your access key. Paste the `ecl_…` key E&P sent you when your account was
provisioned, and approve. ChatGPT remembers the connection from then on.

ChatGPT does not accept an access key sent as a header, so this browser step is the only
route. If the key is lost or exposed, ask E&P to issue a replacement — the old one is
revoked immediately.

## Your own data

This plugin does **not** declare a connector to your ServiceNow, and E&P has no access to
it. Assessments run against evidence you supply in your own session — see
"What you need to bring" in the README. If your workspace has a ServiceNow connector, the
skill will use it when it is present.
