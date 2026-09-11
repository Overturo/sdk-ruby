# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Comply::ResidencyPosture do
  let(:client) { test_client }
  let(:residency_posture) { client.comply.residency_posture }

  describe "#get" do
    it "reads the per-country posture and assurance status" do
      stub_api(:get, "/residency_posture", body: {
                 "residency_map" => { "IT" => { "subjects" => 12 } },
                 "assurance" => "assured",
                 "disclosure_ledger" => [],
                 "generated_at" => "2026-06-26T12:00:00Z"
               })

      result = residency_posture.get
      expect(result.assurance).to eq("assured")
      expect(result.residency_map["IT"]["subjects"]).to eq(12)
    end
  end

  describe "#evidence_package" do
    it "requests the signed Proof of Residency export" do
      stub_api(:post, "/residency_posture/evidence_package", body: {
                 "evidence_package_id" => "ep_rp_1", "format_type" => "residency_posture_v1", "package" => { "merkle_root" => "def" }
               })

      result = residency_posture.evidence_package
      expect(result.evidence_package_id).to eq("ep_rp_1")
      expect(result.format_type).to eq("residency_posture_v1")
    end
  end
end
