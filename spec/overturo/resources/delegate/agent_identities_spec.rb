# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Delegate::AgentIdentities do
  let(:client) { test_client }
  let(:agent_identities) { client.delegate_ns.agent_identities }

  describe "#create" do
    it "creates an agent identity" do
      stub = stub_request(:post, "https://overturo.com/api/v1/agent_identities")
             .with(body: '{"name":"Research Agent","model":"claude-3"}')
             .to_return(
               status: 201,
               body: '{"agent_identity":{"id":"ai_1","name":"Research Agent","status":"active"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = agent_identities.create(name: "Research Agent", model: "claude-3")
      expect(stub).to have_been_requested
      expect(result.id).to eq("ai_1")
      expect(result.status).to eq("active")
    end
  end

  describe "#list" do
    it "lists agent identities" do
      stub_api(:get, "/agent_identities", body: {
                 "agent_identities" => [{ "id" => "ai_1" }, { "id" => "ai_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = agent_identities.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#delegate" do
    it "sends POST to delegate with scopes" do
      stub = stub_request(:post, "https://overturo.com/api/v1/agent_identities/ai_1/delegate")
             .with(body: '{"scopes":["read:profile","write:consent"],"ttl":3600}')
             .to_return(
               status: 200,
               body: '{"agent_identity":{"id":"ai_1","status":"delegated","delegated_scopes":["read:profile","write:consent"]}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = agent_identities.delegate("ai_1", scopes: ["read:profile", "write:consent"], ttl: 3600)
      expect(stub).to have_been_requested
      expect(result.status).to eq("delegated")
      expect(result.delegated_scopes).to eq(["read:profile", "write:consent"])
    end
  end

  describe "#suspend" do
    it "sends POST to suspend with reason" do
      stub = stub_request(:post, "https://overturo.com/api/v1/agent_identities/ai_1/suspend")
             .with(body: '{"reason":"anomalous_behavior"}')
             .to_return(
               status: 200,
               body: '{"agent_identity":{"id":"ai_1","status":"suspended"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = agent_identities.suspend("ai_1", reason: "anomalous_behavior")
      expect(stub).to have_been_requested
      expect(result.status).to eq("suspended")
    end
  end

  describe "#reactivate" do
    it "sends POST to reactivate" do
      stub = stub_request(:post, "https://overturo.com/api/v1/agent_identities/ai_1/reactivate")
             .to_return(
               status: 200,
               body: '{"agent_identity":{"id":"ai_1","status":"active"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = agent_identities.reactivate("ai_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("active")
    end
  end

  describe "error handling" do
    it "raises ForbiddenError when lacking delegation permissions" do
      stub_api(:post, "/agent_identities/ai_1/delegate", status: 403, body: { error: "Insufficient delegation permissions" })

      expect { agent_identities.delegate("ai_1") }.to raise_error(Overturo::ForbiddenError, "Insufficient delegation permissions")
    end
  end
end
