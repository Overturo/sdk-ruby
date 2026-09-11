# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Protect::Policies do
  let(:client) { test_client }
  let(:policies) { client.protect.policies }

  describe "#create" do
    it "creates a policy" do
      stub = stub_request(:post, "https://overturo.com/api/v1/policies")
             .with(body: '{"title":"Privacy Policy","type":"touchpoint"}')
             .to_return(
               status: 201,
               body: '{"policy":{"id":"pol_1","title":"Privacy Policy","status":"draft"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = policies.create(title: "Privacy Policy", type: "touchpoint")
      expect(stub).to have_been_requested
      expect(result.id).to eq("pol_1")
      expect(result.status).to eq("draft")
    end
  end

  describe "#activate" do
    it "activates a policy" do
      stub_request(:post, "https://overturo.com/api/v1/policies/pol_1/activate")
        .to_return(
          status: 200,
          body: '{"policy":{"id":"pol_1","status":"active"}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = policies.activate("pol_1")
      expect(result.status).to eq("active")
    end
  end

  describe "#revoke" do
    it "revokes a policy" do
      stub_request(:post, "https://overturo.com/api/v1/policies/pol_1/revoke")
        .to_return(
          status: 200,
          body: '{"policy":{"id":"pol_1","status":"revoked"}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = policies.revoke("pol_1")
      expect(result.status).to eq("revoked")
    end
  end

  describe "#list" do
    it "lists policies with pagination" do
      stub_api(:get, "/policies", body: {
                 "policies" => [
                   { "id" => "pol_1", "title" => "Policy A" },
                   { "id" => "pol_2", "title" => "Policy B" }
                 ],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = policies.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
      expect(result.pagination["total"]).to eq(2)
    end
  end

  describe "error handling" do
    it "raises NotFoundError for missing policy" do
      stub_api(:get, "/policies/nonexistent", status: 404, body: { error: "Policy not found" })

      expect { policies.retrieve("nonexistent") }.to raise_error(Overturo::NotFoundError, "Policy not found")
    end

    it "raises AuthenticationError for bad API key" do
      stub_api(:get, "/policies", status: 401, body: { error: "Invalid API key" })

      expect { policies.list }.to raise_error(Overturo::AuthenticationError)
    end
  end
end
