# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Delegate::Delegations do
  let(:client) { test_client }
  let(:delegations) { client.delegate_ns.delegations }

  describe "#create" do
    it "creates a delegation, sending the payload the API accepted" do
      stub = ApiCorpus.stub!("Delegations_create", with_body: true)

      result = delegations.create(ApiCorpus.request("Delegations_create")["body"])
      expect(stub).to have_been_requested
      expect(result.id).to eq("<PREFIX_ID:2>")
      expect(result.status).to eq("active")
      expect(result.delegation_type).to eq("peer")
    end
  end

  describe "#retrieve" do
    it "reads one delegation" do
      ApiCorpus.stub!("Delegations_show")

      expect(delegations.retrieve("del_1").delegation_type).to eq("guardian")
    end
  end

  describe "#update" do
    it "sends PATCH with the payload the API accepted" do
      stub = ApiCorpus.stub!("Delegations_update", with_body: true)

      result = delegations.update("del_1", ApiCorpus.request("Delegations_update")["body"])
      expect(stub).to have_been_requested
      expect(result.status).to eq("active")
    end
  end

  describe "#revoke" do
    it "sends DELETE to /delegations/:id/revoke" do
      stub = ApiCorpus.stub!("Delegations_revoke")

      result = delegations.revoke("del_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("revoked")
    end
  end

  describe "#list" do
    it "lists delegations" do
      ApiCorpus.stub!("Delegations_index")

      result = delegations.list
      expect(result.data.size).to eq(1)
      expect(result.data.first.status).to eq("active")
    end
  end
end
