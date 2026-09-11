# Changelog

## [Unreleased]

### Changed

- Repository, homepage, and issue-tracker metadata point at the public source mirror under https://github.com/overturo (spec 192); a LICENSE file now ships with the package.

## [0.4.0] - 2026-08-15

Spec: [`docs/specifications/189-DECISIONS-PREFLIGHT-DISCOVERY-SPEC.md`](../../docs/specifications/189-DECISIONS-PREFLIGHT-DISCOVERY-SPEC.md)

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

Spec: [`docs/specifications/180-AUTHORITY-SDK-SURFACE-SPEC.md`](../../docs/specifications/180-AUTHORITY-SDK-SURFACE-SPEC.md)

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

Spec: [`docs/specifications/126-SX-5-BACKEND-SDKS-SPEC.md`](../../docs/specifications/126-SX-5-BACKEND-SDKS-SPEC.md)

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
