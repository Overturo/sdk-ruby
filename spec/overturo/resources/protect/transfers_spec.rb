# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Protect::Transfers do
  let(:client) { test_client }
  let(:transfers) { client.protect.transfers }

  describe "#create" do
    it "creates a transfer" do
      stub = stub_request(:post, "https://overturo.com/api/v1/transfers")
             .with(body: '{"destination":"app_2","data_types":["profile"]}')
             .to_return(
               status: 201,
               body: '{"transfer":{"id":"tfr_1","status":"pending"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = transfers.create(destination: "app_2", data_types: ["profile"])
      expect(stub).to have_been_requested
      expect(result.id).to eq("tfr_1")
      expect(result.status).to eq("pending")
    end
  end

  describe "#list" do
    it "lists transfers" do
      stub_api(:get, "/transfers", body: {
                 "transfers" => [{ "id" => "tfr_1" }, { "id" => "tfr_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = transfers.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#cancel" do
    it "sends POST to cancel with reason" do
      stub = stub_request(:post, "https://overturo.com/api/v1/transfers/tfr_1/cancel")
             .with(body: '{"reason":"user_requested"}')
             .to_return(
               status: 200,
               body: '{"transfer":{"id":"tfr_1","status":"cancelled"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = transfers.cancel("tfr_1", reason: "user_requested")
      expect(stub).to have_been_requested
      expect(result.status).to eq("cancelled")
    end
  end
end
