---
title: "Ingest Tokens"
weight: 1
aliases: ["/sending_data_to_humio/ingest-tokens", "sending-data-to-humio/ingest_tokens"]
---

Humio has two kinds of API tokens. The _Personal API Tokens_ and _Ingest Tokens_.

## Personal API Token {#personal}

All users have a Personal API Token, you can find it in your account settings page.
This is used for accessing the management API, e.g. creating new repositories.
These tokens should NOT be used for sending data to Humio, even though this is strictly
possible. That is where ingest tokens come in.


## Ingest Tokens {#ingest}

Unlike Personal API Tokens you cannot use Ingest Tokens to manage Humio.
Ingest tokens are a per-repository token that allows you to send data to a specific repository.
They are also write-only meaning you cannot query Humio, log in, or read any data.

Ingest tokens are tied to a repository instead of a user. This provides an
better way of managing access control and is more convenient for most use cases.

For example if a user leaves the organization or project, you do not need to
re-provision all agents that send data with a new token. You also don't have to
create fake "Bot" user accounts.

You can manage your ingest tokens in the **Settings** tab in each repository.

### Assigning a Token to a Parser {#assign-a-parser}

See how to assign a parser to an ingest token in the [parser docs]({{< ref "assigning-parsers-to-ingest-tokens.md" >}}).
