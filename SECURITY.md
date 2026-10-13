# Security

## Reporting a vulnerability

Email **ping@einar.partners** with "Security" in the subject. Describe what you found and
how to reproduce it. Please do not open a public issue or PR for a security problem, and
give us reasonable time to fix it before disclosing it.

This covers the plugin in this repository and the E&P Knowledge Base service it connects
to (`uplink.einar.partners`).

## A leaked or lost access key

Your `ecl_…` key gives access to the Knowledge Base under your organisation's account.
If it may have been exposed — committed to a repository, pasted into a shared chat, sent
to the wrong person — email **ping@einar.partners** at once. E&P revokes the key and
issues a replacement; the old key stops working immediately.

Removing the key from a file or a commit afterwards is not enough: assume anything that
was ever public has been copied.

## What this plugin does not hold

The plugin contains no keys and no client data, and it sends your data nowhere. Your
evidence stays in your own AI client; only your Knowledge Base queries reach E&P.
