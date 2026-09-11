# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Delegate::Delegations do
  let(:client) { test_client }
  let(:delegations) { client.delegate_ns.delegations }

  describe "#create" do
    it "creates a delegation" do
      stub = stub_request(:post, "https://overturo.com/api/v1/delegations")
             .with(body: '{"delegate_id":"usr_2","scope":"read:profile"}')
             .to_return(
               status: 201,
               body: '{"delegation":{"id":"del_1","status":"active"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = delegations.create(delegate_id: "usr_2", scope: "read:profile")
      expect(stub).to have_been_requested
      expect(result.id).to eq("del_1")
    end
  end

  describe "#revoke" do
    it "sends DELETE to /delegations/:id/revoke" do
      stub_request(:delete, "https://overturo.com/api/v1/delegations/del_1/revoke")
        .to_return(
          status: 200,
          body: '{"delegation":{"id":"del_1","status":"revoked"}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = delegations.revoke("del_1")
      expect(result.status).to eq("revoked")
    end
  end

  describe "#list" do
    it "lists delegations" do
      stub_api(:get, "/delegations", body: {
                 "delegations" => [{ "id" => "del_1" }, { "id" => "del_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = delegations.list
      expect(result.data.size).to eq(2)
    end
  end
end
