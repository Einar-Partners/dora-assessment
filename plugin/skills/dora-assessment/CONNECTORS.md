# Connectors

This plugin bundles one connector: the E&P Knowledge Base. That is the only thing it
needs to declare, because it is the only system E&P operates on your behalf.

| Connector name (in `.mcp.json`) | Endpoint | Used for |
|---|---|---|
| `dora-knowledge-base` | `https://uplink.einar.partners/dora/mcp` | The DORA library, organised by pillar (currently all five pillars: checks, regulation, field references, ServiceNow design), loaded with `get_document` — the skill's sole source of assessment criteria |

## Authorising it

**Installing the plugin declares this server. It does not sign you in.** The first time
the skill uses it, your client will start an authorisation flow: a browser window opens
and asks for your access key. Paste the `ecl_…` key E&P sent you when your account was
provisioned, and approve. Your client remembers the connection from then on.

If you use a programmatic client (Claude Code, n8n, CI, your own agent) you can skip the
browser step and send the key as a header instead:

```
Authorization: Bearer ecl_…
```

Both routes resolve to the same key, so there is one credential to look after. If the key
is lost or exposed, ask E&P to issue a replacement — the old one is revoked immediately.

## Your own data

This plugin does **not** declare a connector to your ServiceNow, and E&P has no access to
it. Assessments run against evidence you supply in your own session — see
"What you need to bring" in the README. If you have a ServiceNow MCP connector, add it to
your own client configuration; the skill will use it when it is present.

## SharePoint

No SharePoint document library is configured in this deployment, so the skill's SharePoint
step does not apply: evidence that would have come from one is reported as
`not determinable`.

To configure one, add a `## Tenant-specific configuration` section below, in your own
installed copy of this file, with a single document library URL. Add a SharePoint (Microsoft
365) connector to your own client configuration, not to the plugin. The skill reads only
that one library.
