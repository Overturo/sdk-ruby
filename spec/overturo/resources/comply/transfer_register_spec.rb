# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Comply::TransferRegister do
  let(:client) { test_client }
  let(:transfer_register) { client.comply.transfer_register }

  describe "#list" do
    it "lists the cross-border transfer entries" do
      stub_api(:get, "/transfer_register", body: {
                 "transfers" => [
                   { "id" => "tr_1", "basis" => "adequacy", "adequacy_verdict" => "adequate", "country_pair" => "DE->IT" }
                 ],
                 "flagged_count" => 0
               })

      result = transfer_register.list
      expect(result.data.first.id).to eq("tr_1")
      expect(result.data.first.adequacy_verdict).to eq("adequate")
    end
  end

  describe "#evidence_package" do
    it "requests the signed, verifiable evidence package export" do
      stub_api(:post, "/transfer_register/evidence_package", body: {
                 "evidence_package_id" => "ep_tr_1", "format_type" => "transfer_register_v1", "package" => { "merkle_root" => "abc" }
               })

      result = transfer_register.evidence_package
      expect(result.evidence_package_id).to eq("ep_tr_1")
      expect(result.format_type).to eq("transfer_register_v1")
    end
  end
end
