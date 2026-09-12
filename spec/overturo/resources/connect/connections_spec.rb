# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Connect::Connections do
  let(:client) { test_client }
  let(:connections) { client.connect.connections }

  describe "#list" do
    it "lists connections" do
      ApiCorpus.stub!("Connections_index")

      result = connections.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(1)
      expect(result.data.first.status).to eq("connected")
    end
  end

  describe "#retrieve" do
    it "reads one connection" do
      ApiCorpus.stub!("Connections_show")

      result = connections.retrieve("conn_1")
      expect(result.id).to eq("<PREFIX_ID:1>")
      expect(result.application_id).to be_a(String)
    end
  end

  describe "#suspend" do
    it "sends POST to suspend" do
      stub = ApiCorpus.stub!("Connections_suspend", with_body: true)

      result = connections.suspend("conn_1", ApiCorpus.request("Connections_suspend")["body"])
      expect(stub).to have_been_requested
      expect(result.status).to eq("suspended")
    end
  end

  describe "#unsuspend" do
    it "sends POST to unsuspend" do
      stub = ApiCorpus.stub!("Connections_unsuspend")

      result = connections.unsuspend("conn_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("connected")
    end
  end

  describe "#delete" do
    it "disconnects" do
      ApiCorpus.stub!("Connections_destroy")

      expect(connections.delete("conn_1").status).to eq("disconnected")
    end
  end

  describe "error handling" do
    it "raises NotFoundError for missing connection" do
      stub_api(:get, "/connections/nonexistent", status: 404, body: { error: "Connection not found" })

      expect { connections.retrieve("nonexistent") }.to raise_error(Overturo::NotFoundError)
    end
  end
end
