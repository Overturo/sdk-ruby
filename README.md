> **Release mirror.** This repository is a read-only snapshot of
> `overturo` 0.4.0, published from Overturo's main
> development repository. Issues and pull requests are welcome here; accepted
> changes are ported upstream and appear in the next release snapshot.
> Security reports: see [SECURITY.md](./SECURITY.md).

# Overturo Ruby SDK

Ruby client for the [Overturo](https://overturo.com) personal data identity platform API.

## Installation

Add to your Gemfile:

```ruby
gem "overturo"
```

Or install directly:

```bash
gem install overturo
```

**Requirements:** Ruby >= 3.1. Zero runtime dependencies.

## Quick Start

```ruby
require "overturo"

client = Overturo::Client.new(api_key: "sk_live_...")

# Get the current user
me = client.core.me.retrieve
puts me.email

# List applications
apps = client.connect.applications.list
apps.each { |app| puts app.name }

# Create a policy
policy = client.protect.policies.create(
  title: "Data Access Policy",
  type: "touchpoint"
)

# Activate a flow
client.connect.flows.activate("flw_abc123")
```

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `api_key` | **required** | Your API key (`sk_live_...` or `sk_test_...`) |
| `base_url` | `https://overturo.com` | API base URL |
| `api_version` | `v1` | API version |
| `open_timeout` | `30` | Connection open timeout (seconds) |
| `read_timeout` | `80` | Read timeout (seconds) |
| `write_timeout` | `30` | Write timeout (seconds) |
| `max_retries` | `2` | Max retries on transient failures (429, 5xx, network) |
| `logger` | `nil` | Logger instance for request/response logging |

```ruby
client = Overturo::Client.new(
  api_key: "sk_live_...",
  base_url: "https://custom.endpoint.com",
  max_retries: 3,
  read_timeout: 120,
  logger: Logger.new($stdout)
)
```

## Surfaces & Resources

The API is organized into 8 surfaces with 28 resources:

| Surface | Accessor | Resources |
|---------|----------|-----------|
| **Core** | `client.core` | `me`, `accounts` |
| **Connect** | `client.connect` | `applications`, `webhooks`, `connections`, `trust_pairings`, `flows` |
| **Consent** | `client.consent` | `consent_sessions`, `entitlements`, `trust_levels` |
| **Verify** | `client.verify` | `credentials`, `verification_sessions`, `presentations`, `trust_scores`, `vouches` |
| **Protect** | `client.protect` | `policies`, `data_requests`, `transfers`, `data_licenses` |
| **Agree** | `client.agree` | `agreements`, `decisions`, `collaborations` |
| **Delegate** | `client.delegate_ns` | `delegations`, `agent_identities`, `security_event_streams` |
| **Comply** | `client.comply` | `anchors`, `evidence_packages`, `clean_rooms` |

## Usage

### CRUDL Operations

```ruby
# Create
app = client.connect.applications.create(name: "My App", redirect_uri: "https://example.com/callback")

# Retrieve
app = client.connect.applications.retrieve("app_abc123")

# Update
app = client.connect.applications.update("app_abc123", name: "New Name")

# Delete
client.connect.applications.delete("app_abc123")

# List
apps = client.connect.applications.list(page: 1, per_page: 25)
```

### Custom Actions

Resources expose domain-specific actions beyond standard CRUDL:

```ruby
# Application lifecycle
client.connect.applications.publish("app_1")
client.connect.applications.unpublish("app_1")

# Flow lifecycle (draft → active → deprecated → archived)
client.connect.flows.activate("flw_1")
client.connect.flows.deprecate("flw_1", successor_id: "flw_2")
client.connect.flows.archive("flw_1")

# Connection management
client.connect.connections.suspend("conn_1", reason: "policy_violation")
client.connect.connections.unsuspend("conn_1")

# Consent verification
result = client.consent.entitlements.verify("ent_1", scope: "read:profile")
result.valid    # => true
result.scopes   # => ["read:profile"]

# Trust score queries
score = client.verify.trust_scores.query(subject: "usr_1", context: "data_sharing")
score.score     # => 0.85

# Vouch management
vouches = client.verify.vouches.received(claim: "identity_verified")
vouches.data    # => [OverturoObject, ...]

# Agreement negotiation
client.agree.agreements.propose(title: "Data sharing", counterparty_id: "usr_2")
client.agree.agreements.accept("agr_1")
client.agree.agreements.counter("agr_1", terms: "revised terms")

# Quorum decisions
client.agree.decisions.vote("dec_1", choice: "approve", comment: "Looks good")

# Multi-party collaboration
client.agree.collaborations.invite("collab_1", email: "partner@example.com", role: "contributor")
client.agree.collaborations.sign("collab_1")

# Agent identity delegation
client.delegate_ns.agent_identities.delegate("ai_1", scopes: ["read:profile"], ttl: 3600)
client.delegate_ns.agent_identities.suspend("ai_1", reason: "anomalous_behavior")
client.delegate_ns.agent_identities.reactivate("ai_1")

# Security event stream polling
events = client.delegate_ns.security_event_streams.poll("ses_1", cursor: "cur_abc")
events.events   # => [OverturoObject, ...]
events.cursor   # => "cur_def"

# Policy management
client.protect.policies.activate("pol_1")
client.protect.policies.revoke("pol_1")

# Data transfer cancellation
client.protect.transfers.cancel("tfr_1", reason: "user_requested")

# Data license termination
client.protect.data_licenses.terminate("dl_1", reason: "contract_expired")

# Clean room approval
client.comply.clean_rooms.approve("cr_1")

# Audit anchor inspection
anchor = client.comply.anchors.retrieve("anc_1")
export = client.comply.anchors.export("anc_1", format: "json")
receipts = client.comply.anchors.receipts("anc_1")
```

### Pagination

List endpoints return `ListObject` instances with built-in pagination:

```ruby
# Manual pagination
page = client.connect.applications.list(page: 1, per_page: 10)
page.data         # => Array of OverturoObject
page.has_more?    # => true/false
page.pagination   # => {"page" => 1, "per_page" => 10, "total" => 42}

# Fetch next page
next_page = page.next_page

# Auto-pagination across all pages
client.connect.applications.list.auto_paging_each do |app|
  puts app.name
end
```

### Nested Resources

Webhooks are scoped to an application:

```ruby
webhooks = client.connect.webhooks

# Create a webhook for an application
webhook = webhooks.create("app_1",
  url: "https://example.com/webhook",
  events: ["policy.activated"]
)

# List webhooks for an application
webhooks.list("app_1")

# Retrieve a specific webhook
webhooks.retrieve("app_1", "wh_1")

# Delete a webhook
webhooks.delete("app_1", "wh_1")
```

### Consent Sessions

The consent flow uses session tokens for iframe/embed integration:

```ruby
sessions = client.consent.consent_sessions

# Create a consent session
session = sessions.create(flow_id: "flw_1", delivery_mode: "redirect")
session.session_token  # => "tok_abc"

# Authorize the session (after user grants consent)
sessions.authorize("cs_1")

# Exchange session for tokens
tokens = sessions.exchange("cs_1")
tokens.access_token  # => "at_123"
```

### Cross-border compliance

```ruby
# Cross-border transfer register — each entry carries its lawful basis,
# adequacy verdict, and country pair. Export a signed, verifiable package.
register = client.comply.transfer_register
register.list                       # => list of transfer entries
register.evidence_package           # => signed, anchored evidence package

# Residency posture — where your subjects' data is stored, per country.
posture = client.comply.residency_posture
posture.get                         # => per-country posture + assurance status
posture.evidence_package            # => signed Proof of Residency

# Data portability (Art. 20) — application-scoped
client.connect.portability.formats("app_1")
client.connect.portability.confirm_export("app_1", portability_transfer_id: "pt_1")

# Compute-to-data — a result carries its privacy parameters and a first-class
# `suppressed` flag; a full k-anonymity suppression is surfaced, never empty.
result = client.comply.clean_rooms.run_query("cr_1", query: { ... })
result.suppressed                   # => true/false
result.k_anonymity_met              # => true/false
```

Country and assurance metadata ride the response objects (a country, never an
internal code).

## Error Handling

All errors inherit from `Overturo::Error` and carry `http_status`, `http_body`, and `json_body` attributes.

| Error Class | HTTP Status | Description |
|-------------|-------------|-------------|
| `AuthenticationError` | 401 | Invalid or missing API key |
| `ForbiddenError` | 403 | Insufficient permissions |
| `NotFoundError` | 404 | Resource not found |
| `InvalidRequestError` | 400, 422 | Malformed request or validation failure |
| `RateLimitError` | 429 | Too many requests |
| `ApiError` | 500+ | Server-side error |
| `ConnectionError` | — | Network connectivity failure |
| `TimeoutError` | — | Request timed out |

```ruby
begin
  client.connect.flows.activate("flw_nonexistent")
rescue Overturo::NotFoundError => e
  puts "Not found: #{e.message}"
  puts "Status: #{e.http_status}"    # => 404
  puts "Body: #{e.json_body}"        # => {"error" => "..."}
rescue Overturo::InvalidRequestError => e
  puts "Validation failed: #{e.message}"  # e.g. "Flow must be in draft status to activate"
rescue Overturo::RateLimitError
  puts "Rate limited — retry later"
rescue Overturo::AuthenticationError
  puts "Check your API key"
rescue Overturo::Error => e
  puts "Unexpected error: #{e.message}"
end
```

## Retries & Idempotency

The client automatically retries on transient failures (HTTP 429, 5xx, network errors, timeouts) up to `max_retries` times with exponential backoff (0.5s, 1s, 2s, ...).

POST and PATCH requests include an `Idempotency-Key` header to ensure safe retries. You can also provide your own:

```ruby
client.connect.applications.create(
  { name: "My App" },
  idempotency_key: "my-unique-key-123"
)
```

## Thread Safety

Each `Client` instance is safe to use across threads. Surface accessors and resources are memoized per-client, and `Net::HTTP` connections are created per-request. Create one client and share it:

```ruby
# config/initializers/overturo.rb
OVERTURO = Overturo::Client.new(api_key: ENV["OVERTURO_API_KEY"])

# Anywhere in your app
OVERTURO.connect.applications.list
```

## License

Proprietary. Copyright OmVi Labs Inc

## Authority records

The durable **Authorization Receipt** is a different artifact from the
short-lived runtime receipt of the authorize path — the runtime
receipt's TTL bounds *honoring*, not evidence, while the durable record
is the archival, offline-verifiable account of the authorization.

```ruby
# The durable record (audit:verify scope). Flavors: canonical (default,
# unwrapped like every resource read), signed and dpv (returned as
# plain Hashes — portable artifacts).
record = client.delegate_ns.authorization_receipts.retrieve("acc_...")
envelope = client.delegate_ns.authorization_receipts.retrieve("acc_...", flavor: "signed")

# Mint an operator-declared disclosure receipt (disclosures:write scope).
minted = client.delegate_ns.disclosure_receipts.create(
  flow_id: "acc_...", agent_id: "agt_...", disclosed_at: Time.now.utc.iso8601
)
```

Typed refusals raise `Overturo::InvalidRequestError` carrying the
machine code in `error_code` (`unknown_flavor`, `not_signable`,
`dpv_unavailable`; `agent_not_disclosed`, `invalid_disclosed_at`,
`purposes_missing`). The 404 contract is parity-preserving: unknown,
foreign, and non-authority ids are indistinguishable. An
authorization-kind record is refused by the consent-receipts read with
a typed hint — authority records are served only by these endpoints.
The gem stays dependency-free, so signed-record verification in Ruby is
the worked recipe in the Receipt Interop & Verification guide (gated by
the shared conformance corpus); in Node and Python it is a library call
(`@overturo/verify`, `overturo.verify_record`).
