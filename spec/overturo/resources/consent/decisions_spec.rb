# frozen_string_literal: true

require "spec_helper"

# 189 — pre-flight disclosure discovery. Decodes the shared conformance fixture
# (lib/sdk/shared/conformance/discovery/flow_disclosures.json) — the same corpus
# the server + the other three clients hold.
RSpec.describe Overturo::Resources::Consent::Decisions do
  let(:client) { test_client }
  let(:decisions) { client.consent.decisions }
  let(:pk) { "pk_test_x" }
  let(:flow_id) { "flw_test_discovery" }
  let(:disclosures_url) { "https://overturo.com/api/v1/decisions/flows/#{flow_id}/disclosures" }
  let(:fixture_body) do
    # The shared fixture when this gem sits next to it; the vendored copy otherwise.
    shared = File.expand_path("../../../../../shared/conformance/discovery/flow_disclosures.json", __dir__)
    File.read(File.exist?(shared) ? shared : File.expand_path("../../../fixtures/discovery/flow_disclosures.json", __dir__))
  end

  describe "#discover" do
    it "decodes the shared fixture into the inventory object" do
      stub = stub_request(:get, disclosures_url)
             .with(headers: { "X-Publishable-Key" => pk })
             .to_return(status: 200, body: fixture_body, headers: { "Content-Type" => "application/json" })

      result = decisions.discover(flow_id, publishable_key: pk)

      expect(stub).to have_been_requested
      expect(result.schema).to eq("overturo-disclosure/1")
      expect(result.flow.kind).to eq("consent")
      expect(result.application.primary_color).to eq("#0B5FFF")
      expect(result.expiry.consent_duration_days).to eq(365)
      expect(result.locale.fallback).to eq("en")
      purpose = result.purposes.find { |p| p.name == "care_reminders" }
      expect(purpose.mechanism).to eq("opt_out")
      expect(purpose.legal_basis).to eq("consent")
      expect(result.fields.map(&:completed_by)).to include("principal")
      expect(result.outcomes).to eq(%w[granted denied])
    end

    it "sends the publishable key header and the locale query" do
      stub = stub_request(:get, disclosures_url)
             .with(query: { locale: "de" }, headers: { "X-Publishable-Key" => pk })
             .to_return(status: 200, body: fixture_body, headers: { "Content-Type" => "application/json" })

      decisions.discover(flow_id, publishable_key: pk, locale: "de")
      expect(stub).to have_been_requested
    end

    it "raises ArgumentError before any request when flow_id or publishable_key is blank" do
      expect { decisions.discover("", publishable_key: pk) }.to raise_error(ArgumentError)
      expect { decisions.discover(flow_id, publishable_key: "") }.to raise_error(ArgumentError)
    end

    it "maps the uniform 404 to NotFoundError" do
      stub_request(:get, disclosures_url)
        .to_return(status: 404,
                   body: '{"error":{"code":"flow_not_found","message":"Flow not found"}}',
                   headers: { "Content-Type" => "application/json" })

      expect { decisions.discover(flow_id, publishable_key: pk) }.to raise_error(Overturo::NotFoundError)
    end

    it "raises a typed error on an envelope-less 200 (never masks a wrong body as the inventory)" do
      stub_request(:get, disclosures_url)
        .to_return(status: 200, body: '{"unexpected":true}', headers: { "Content-Type" => "application/json" })

      expect { decisions.discover(flow_id, publishable_key: pk) }
        .to raise_error(Overturo::ApiError, /missing 'flow'/)
    end

    it "omits the locale query for a blank locale (parity with the JS/py clients)" do
      stub = stub_request(:get, disclosures_url) # no query — a ?locale= request would not match
             .to_return(status: 200, body: fixture_body, headers: { "Content-Type" => "application/json" })

      decisions.discover(flow_id, publishable_key: pk, locale: "")
      expect(stub).to have_been_requested
    end

    it "does not double the slash when base_url carries a trailing slash" do
      slashed = Overturo::Client.new(api_key: "sk_test_123", base_url: "https://overturo.com/")
      stub = stub_request(:get, disclosures_url) # single-slash canonical URL
             .with(headers: { "X-Publishable-Key" => pk })
             .to_return(status: 200, body: fixture_body, headers: { "Content-Type" => "application/json" })

      slashed.consent.decisions.discover(flow_id, publishable_key: pk)
      expect(stub).to have_been_requested
    end
  end
end
