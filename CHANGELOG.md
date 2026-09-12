# Changelog

## [0.5.3] - 2026-09-12

### Changed

- The README links the public documentation and the rendered API reference at overturo.com/developers; the vendored API response corpus is re-recorded against the published document, whose operations now list the SDKs that reach them (`x-overturo-sdks`).
- The discovery spec reads a vendored copy of the shared discovery fixture (`spec/fixtures/discovery/`) when the shared corpus is not present, so the published gem's suite is self-contained.

## [0.5.2] - 2026-09-11

### Fixed

- `delegations` now reads the `delegation_grant` / `delegation_grants` response keys the API actually returns; every delegation call previously came back as the raw envelope.
- `webhooks` now reads the `webhook_subscription` / `webhook_subscriptions` response keys, for the same reason.
- Errors read the API's `{error: {code, message}}` envelope: `error_code` is the code (it was the whole envelope) and the message is `code: message`.
- `accounts.list` now reads the bare collection the accounts API renders (it came back empty before).
- `nested_resource` no longer derives the generated `list_*` method name from the response key (`list_method:` sets it explicitly), so the public method names are unchanged.

## [0.5.1] - 2026-09-11

### Changed

- Source comments and this changelog describe behaviour only: planning references, section marks, and notes about earlier server behaviour were removed. A consent-session test fixture now uses the public `flow_id` key.

## [0.5.0] - 2026-09-11

### Changed

- **Licence: Apache-2.0** (was MIT, a scaffold default). One outbound licence for every Overturo SDK — explicit patent grant, trademark exclusion, and contribution terms.

## [0.4.2] - 2026-09-11

### Changed

- Copyright holder in LICENSE and README is Overturo Geneva Association (the steward of the open-source libraries); 0.4.1 named a company by mistake.

## [0.4.1] - 2026-09-11

### Changed

- Repository, homepage, and issue-tracker metadata point at the public source mirror under https://github.com/overturo; a LICENSE file now ships with the package.
- README License section corrected: the gem is MIT-licensed (as the gemspec has always declared); the earlier "Proprietary" line was wrong.

## [0.4.0] - 2026-08-15

### Added — pre-flight disclosure discovery

- **`client.consent.decisions.discover(flow_id, publishable_key:, locale: nil)`**
  — fetch what a consent flow would ask a person (purposes, fields, steps, the
  action label, expiry, application branding) BEFORE any session exists, in
  public vocabulary and the requested locale. The publishable key is an
  embed-safe, per-application credential passed explicitly per call (this
  endpoint ignores the client's bearer token). An unknown / foreign /
  non-consent flow raises `Overturo::NotFoundError`.
- **`HttpClient#get`** now accepts a `headers:` keyword (for the
  `X-Publishable-Key` header).
- Cross-language parity is gated by the shared corpus at
  `lib/sdk/shared/conformance/discovery/flow_disclosures.json`.

## [0.3.0] - 2026-08-06

### Added — authority record client methods

- **`client.delegate_ns.authorization_receipts.retrieve(id, flavor:)`** —
  the durable authorization record (`audit:verify` scope). Canonical
  unwraps like every resource read; `signed`/`dpv` return the portable
  document as a plain Hash. Typed flavor refusals surface via the new
  `Overturo::Error#error_code`.
- **`client.delegate_ns.disclosure_receipts.create(...)`** — the
  operator-declared disclosure mint (`disclosures:write` scope), closed
  payload `flow_id` / `agent_id` / `disclosed_at` / `locale`.
- **`Overturo::Error#error_code`** — the machine code from a structured
  error body, across both authority 422 shapes.

### Compatibility

- Additive, no break. The gem stays dependency-free: signed-record
  verification in Ruby remains the interop guide's recipe, gated by the
  shared corpus (the server's own verifier is the Ruby leg).

## [0.2.0] - 2026-06-26

### Added — cross-border compliance capabilities

- **`comply.transfer_register`** — read the cross-border transfer register
  (`list`), each entry carrying its lawful basis, adequacy verdict, and country
  pair; export the signed, verifiable evidence package (`evidence_package`).
- **`comply.residency_posture`** — read your per-country residency posture and
  assurance status (`get`); export the signed Proof of Residency
  (`evidence_package`).
- **`connect.portability`** — application-scoped data portability (Art. 20):
  `formats`, `confirm_export`, `confirm_import`, each taking the application id
  as its first argument. (The self-service access DSAR is a web-only export and
  is not part of the API surface.)
- **`comply.clean_rooms`** compute-to-data: `run_query` / `queries` / `query`.
  A result carries its privacy parameters (`k_anonymity_met`,
  `noise_parameters`) and a first-class `suppressed` flag + `suppression_reason`
  — a full k-anonymity suppression is surfaced honestly, never a silent empty.

Country and assurance metadata ride the response objects (residency posture
`assurance`; transfer entries' basis / adequacy / country pair).

### Notes

- This SDK does not declare a jurisdiction bound (it has no agent-authorization
  surface) — but a jurisdiction refusal is surfaced via the existing
  `OAPDenied#failed_bound == "jurisdiction_bounds"`, distinct from a
  transport-level refusal.
- First changelog for this SDK. Additive minor; no breaking changes.
