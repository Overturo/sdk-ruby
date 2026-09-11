# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::ApiResource do
  let(:client) { test_client }

  describe "CRUDL operations via AgentIdentities" do
    # AgentIdentities is a full-CRUDL resource; using it as the sample for
    # framework-level tests avoids coupling these tests to any one surface.
    let(:apps) { client.delegate_ns.agent_identities }

    describe "#list" do
      it "returns a ListObject" do
        stub_api(:get, "/agent_identities", body: {
                   "agent_identities" => [
                     { "id" => "ai_1", "name" => "App One" },
                     { "id" => "ai_2", "name" => "App Two" }
                   ],
                   "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
                 })

        result = apps.list
        expect(result).to be_a(Overturo::ListObject)
        expect(result.data.size).to eq(2)
        expect(result.data.first.name).to eq("App One")
      end

      it "passes query params" do
        stub = stub_request(:get, "https://overturo.com/api/v1/agent_identities?page=2&per_page=5")
               .to_return(status: 200, body: '{"agent_identities":[],"pagination":{}}', headers: { "Content-Type" => "application/json" })

        apps.list(page: 2, per_page: 5)
        expect(stub).to have_been_requested
      end
    end

    describe "#retrieve" do
      it "returns an OverturoObject" do
        stub_api(:get, "/agent_identities/ai_123", body: {
                   "agent_identity" => { "id" => "ai_123", "name" => "My App" }
                 })

        result = apps.retrieve("ai_123")
        expect(result).to be_a(Overturo::OverturoObject)
        expect(result.id).to eq("ai_123")
        expect(result.name).to eq("My App")
      end
    end

    describe "#create" do
      it "sends POST and returns OverturoObject" do
        stub = stub_request(:post, "https://overturo.com/api/v1/agent_identities")
               .with(body: '{"name":"New App"}')
               .to_return(
                 status: 201,
                 body: '{"agent_identity":{"id":"ai_new","name":"New App"}}',
                 headers: { "Content-Type" => "application/json" }
               )

        result = apps.create(name: "New App")
        expect(stub).to have_been_requested
        expect(result.id).to eq("ai_new")
      end
    end

    describe "#update" do
      it "sends PATCH and returns OverturoObject" do
        stub = stub_request(:patch, "https://overturo.com/api/v1/agent_identities/ai_123")
               .with(body: '{"name":"Updated"}')
               .to_return(
                 status: 200,
                 body: '{"agent_identity":{"id":"ai_123","name":"Updated"}}',
                 headers: { "Content-Type" => "application/json" }
               )

        result = apps.update("ai_123", name: "Updated")
        expect(stub).to have_been_requested
        expect(result.name).to eq("Updated")
      end
    end

    describe "#delete" do
      it "sends DELETE" do
        stub = stub_request(:delete, "https://overturo.com/api/v1/agent_identities/ai_123")
               .to_return(
                 status: 200,
                 body: '{"agent_identity":{"id":"ai_123","deleted":true}}',
                 headers: { "Content-Type" => "application/json" }
               )

        result = apps.delete("ai_123")
        expect(stub).to have_been_requested
        expect(result.deleted).to be true
      end
    end
  end

  describe "custom_action DSL" do
    let(:policies) { client.protect.policies }

    it "defines action methods that POST to /resource/:id/action" do
      stub = stub_request(:post, "https://overturo.com/api/v1/policies/pol_1/activate")
             .to_return(
               status: 200,
               body: '{"policy":{"id":"pol_1","status":"active"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = policies.activate("pol_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("active")
    end

    it "passes params to action methods" do
      stub = stub_request(:post, "https://overturo.com/api/v1/policies/pol_1/share")
             .with(body: '{"user_id":"usr_1"}')
             .to_return(
               status: 200,
               body: '{"shared":true}',
               headers: { "Content-Type" => "application/json" }
             )

      result = policies.share("pol_1", user_id: "usr_1")
      expect(stub).to have_been_requested
      expect(result.shared).to be true
    end
  end

  describe "collection_action DSL" do
    let(:agreements) { client.agree.agreements }

    it "defines collection actions that POST to /resource/action" do
      stub = stub_request(:post, "https://overturo.com/api/v1/agreements/propose")
             .with(body: '{"title":"Deal"}')
             .to_return(
               status: 201,
               body: '{"agreement":{"id":"agr_1","status":"offered"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = agreements.propose(title: "Deal")
      expect(stub).to have_been_requested
      expect(result.status).to eq("offered")
    end
  end

  describe "#unwrap" do
    let(:apps) { client.delegate_ns.agent_identities }

    it "extracts nested object from response" do
      stub_api(:get, "/agent_identities/ai_1", body: {
                 "agent_identity" => { "id" => "ai_1", "name" => "Test" }
               })

      result = apps.retrieve("ai_1")
      expect(result.id).to eq("ai_1")
    end

    it "handles flat responses gracefully" do
      stub_api(:get, "/agent_identities/ai_1", body: { "id" => "ai_1", "name" => "Test" })

      result = apps.retrieve("ai_1")
      expect(result.id).to eq("ai_1")
    end
  end
end
