# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Consent::Entitlements do
  let(:client) { test_client }
  let(:entitlements) { client.consent.entitlements }

  describe "#list" do
    it "lists entitlements" do
      stub_api(:get, "/entitlements", body: {
                 "entitlements" => [{ "id" => "ent_1" }, { "id" => "ent_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = entitlements.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#verify" do
    it "sends POST to verify and returns raw response (not unwrapped by key)" do
      stub = stub_request(:post, "https://overturo.com/api/v1/entitlements/ent_1/verify")
             .with(body: '{"scope":"read:profile"}')
             .to_return(
               status: 200,
               body: '{"valid":true,"scopes":["read:profile"],"expires_at":"2026-12-31T00:00:00Z"}',
               headers: { "Content-Type" => "application/json" }
             )

      result = entitlements.verify("ent_1", scope: "read:profile")
      expect(stub).to have_been_requested
      expect(result.valid).to be true
      expect(result.scopes).to eq(["read:profile"])
      expect(result.expires_at).to eq("2026-12-31T00:00:00Z")
    end
  end
end
