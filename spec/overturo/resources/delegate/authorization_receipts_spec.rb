# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Delegate::AuthorizationReceipts do
  let(:client) { test_client }

  let(:canonical_body) do
    {
      "authorization_receipt" => {
        "record" => { "record_type" => "authorization_record", "record_id" => "acc_123" },
        "receipt_metadata" => { "status" => "active" }
      }
    }
  end

  let(:signed_envelope) do
    {
      "receipt" => { "record" => { "record_type" => "authorization_record", "record_id" => "acc_123" } },
      "signature" => {
        "algorithm" => "Ed25519",
        "canonicalization" => "overturo-jcs-1",
        "region" => "us",
        "key_version" => "us-1",
        "value" => "c2ln",
        "public_key" => "a2V5",
        "key_discovery" => "https://overturo.com/.well-known/witness-configuration",
        "signed_at" => "2026-08-06T00:00:00Z"
      }
    }
  end

  describe "#retrieve" do
    it "defaults to the canonical flavor with no query and unwraps the document" do
      stub_api(:get, "/authorization_receipts/acc_123", body: canonical_body)

      receipt = client.delegate_ns.authorization_receipts.retrieve("acc_123")

      expect(receipt.record["record_type"]).to eq("authorization_record")
      expect(a_request(:get, "https://overturo.com/api/v1/authorization_receipts/acc_123")
        .with { |req| req.uri.query.nil? }).to have_been_made
    end

    it "passes an explicit canonical flavor through and still unwraps" do
      stub_api(:get, "/authorization_receipts/acc_123", query: { "flavor" => "canonical" }, body: canonical_body)

      receipt = client.delegate_ns.authorization_receipts.retrieve("acc_123", flavor: "canonical")

      expect(receipt.record["record_id"]).to eq("acc_123")
    end

    it "returns the signed flavor as the bare envelope Hash (a portable artifact)" do
      stub_api(:get, "/authorization_receipts/acc_123", query: { "flavor" => "signed" }, body: signed_envelope)

      envelope = client.delegate_ns.authorization_receipts.retrieve("acc_123", flavor: "signed")

      expect(envelope).to be_a(Hash)
      expect(envelope.keys).to contain_exactly("receipt", "signature")
      expect(envelope.dig("signature", "canonicalization")).to eq("overturo-jcs-1")
    end

    it "returns the dpv flavor as a plain Hash even under application/ld+json" do
      dpv = { "@context" => { "dpv" => "https://w3id.org/dpv#" }, "@type" => "dpv:ConsentRecord" }
      stub_request(:get, "https://overturo.com/api/v1/authorization_receipts/acc_123")
        .with(query: { "flavor" => "dpv" })
        .to_return(status: 200, body: dpv.to_json, headers: { "Content-Type" => "application/ld+json" })

      document = client.delegate_ns.authorization_receipts.retrieve("acc_123", flavor: "dpv")

      expect(document).to be_a(Hash)
      expect(document["@type"]).to eq("dpv:ConsentRecord")
    end

    it "surfaces the typed flavor refusals with error_code" do
      {
        "unknown_flavor" => { "error" => "unknown_flavor" },
        "not_signable" => { "error" => "not_signable", "reason" => "no frozen snapshot" },
        "dpv_unavailable" => { "error" => "dpv_unavailable", "reason" => "no personal-data processing" }
      }.each do |code, body|
        stub_api(:get, "/authorization_receipts/acc_123", query: { "flavor" => "bogus" }, status: 422, body: body)

        expect do
          client.delegate_ns.authorization_receipts.retrieve("acc_123", flavor: "bogus")
        end.to raise_error(Overturo::InvalidRequestError) { |e|
          expect(e.error_code).to eq(code)
          expect(e.http_status).to eq(422)
        }
      end
    end

    it "maps the parity-preserving 404" do
      stub_api(:get, "/authorization_receipts/acc_nope", status: 404,
                                                         body: { "error" => "Authorization record not found" })

      expect do
        client.delegate_ns.authorization_receipts.retrieve("acc_nope")
      end.to raise_error(Overturo::NotFoundError)
    end

    it "maps the missing-scope 403" do
      stub_api(:get, "/authorization_receipts/acc_123", status: 403,
                                                        body: { "error" => "Requires audit:verify scope" })

      expect do
        client.delegate_ns.authorization_receipts.retrieve("acc_123")
      end.to raise_error(Overturo::ForbiddenError) { |e|
        expect(e.message).to include("audit:verify")
      }
    end
  end
end
