# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Comply::Anchors do
  let(:client) { test_client }
  let(:anchors) { client.comply.anchors }

  describe "#retrieve" do
    it "retrieves an anchor" do
      stub_api(:get, "/anchors/anc_1", body: {
                 "anchor" => { "id" => "anc_1", "merkle_root" => "abc123", "record_count" => 42 }
               })

      result = anchors.retrieve("anc_1")
      expect(result.id).to eq("anc_1")
      expect(result.merkle_root).to eq("abc123")
    end
  end

  describe "#export" do
    it "exports an anchor" do
      stub = stub_request(:get, "https://overturo.com/api/v1/anchors/anc_1/export?format=json")
             .to_return(
               status: 200,
               body: '{"records":[{"id":"rec_1"}],"merkle_root":"abc123"}',
               headers: { "Content-Type" => "application/json" }
             )

      result = anchors.export("anc_1", format: "json")
      expect(stub).to have_been_requested
      expect(result.merkle_root).to eq("abc123")
    end
  end

  describe "#receipts" do
    it "lists receipts for an anchor" do
      stub_request(:get, "https://overturo.com/api/v1/anchors/anc_1/receipts")
        .to_return(
          status: 200,
          body: '{"receipts":[{"id":"rcpt_1"},{"id":"rcpt_2"}],"pagination":{"page":1,"per_page":25,"total":2}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = anchors.receipts("anc_1")
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
      expect(result.data.first.id).to eq("rcpt_1")
    end
  end
end
