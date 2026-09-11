# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Comply::EvidencePackages do
  let(:client) { test_client }
  let(:evidence_packages) { client.comply.evidence_packages }

  describe "#retrieve" do
    it "retrieves an evidence package" do
      stub_api(:get, "/evidence_packages/ep_1", body: {
                 "evidence_package" => { "id" => "ep_1", "status" => "sealed", "record_count" => 15, "content_hash" => "sha256_abc" }
               })

      result = evidence_packages.retrieve("ep_1")
      expect(result.id).to eq("ep_1")
      expect(result.status).to eq("sealed")
      expect(result.record_count).to eq(15)
      expect(result.content_hash).to eq("sha256_abc")
    end

    it "raises NotFoundError for missing evidence package" do
      stub_api(:get, "/evidence_packages/nonexistent", status: 404, body: { error: "Evidence package not found" })

      expect { evidence_packages.retrieve("nonexistent") }.to raise_error(Overturo::NotFoundError)
    end
  end
end
