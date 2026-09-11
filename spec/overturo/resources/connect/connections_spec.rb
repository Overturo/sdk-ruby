# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Connect::Connections do
  let(:client) { test_client }
  let(:connections) { client.connect.connections }

  describe "#list" do
    it "lists connections with pagination" do
      stub_api(:get, "/connections", body: {
                 "connections" => [{ "id" => "conn_1" }, { "id" => "conn_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = connections.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#suspend" do
    it "sends POST to suspend with reason" do
      stub = stub_request(:post, "https://overturo.com/api/v1/connections/conn_1/suspend")
             .with(body: '{"reason":"policy_violation"}')
             .to_return(
               status: 200,
               body: '{"connection":{"id":"conn_1","status":"suspended"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = connections.suspend("conn_1", reason: "policy_violation")
      expect(stub).to have_been_requested
      expect(result.status).to eq("suspended")
    end
  end

  describe "#unsuspend" do
    it "sends POST to unsuspend" do
      stub = stub_request(:post, "https://overturo.com/api/v1/connections/conn_1/unsuspend")
             .to_return(
               status: 200,
               body: '{"connection":{"id":"conn_1","status":"connected"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = connections.unsuspend("conn_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("connected")
    end
  end

  describe "error handling" do
    it "raises NotFoundError for missing connection" do
      stub_api(:get, "/connections/nonexistent", status: 404, body: { error: "Connection not found" })

      expect { connections.retrieve("nonexistent") }.to raise_error(Overturo::NotFoundError)
    end
  end
end
