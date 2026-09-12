# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Verify::Vouches do
  let(:client) { test_client }
  let(:vouches) { client.verify.vouches }

  describe "#create" do
    it "creates a vouch, sending the payload the API accepted" do
      stub = ApiCorpus.stub!("Vouches_create", with_body: true)

      result = vouches.create(ApiCorpus.request("Vouches_create")["body"])
      expect(stub).to have_been_requested
      expect(result.id).to eq("<PREFIX_ID:3>")
      expect(result.status).to eq("active")
    end
  end

  describe "#list" do
    it "lists vouches" do
      ApiCorpus.stub!("Vouches_index")

      result = vouches.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(1)
    end
  end

  describe "#retrieve" do
    it "reads one vouch with its public policy id" do
      ApiCorpus.stub!("Vouches_show")

      result = vouches.retrieve("vch_1")
      expect(result.id).to eq("<PREFIX_ID:1>")
      expect(result.policy_id).to be_a(String)
    end

    it "maps the documented 404 envelope to NotFoundError" do
      ApiCorpus.stub!("Vouches_show", step: "404")

      expect { vouches.retrieve("vch_missing") }.to raise_error(Overturo::NotFoundError)
    end
  end

  describe "#delete" do
    it "revokes" do
      ApiCorpus.stub!("Vouches_destroy")

      expect(vouches.delete("vch_1").status).to eq("revoked")
    end
  end

  describe "#received" do
    it "sends GET to /vouches/received and returns a ListObject" do
      stub = ApiCorpus.stub!("Vouches_received")

      result = vouches.received
      expect(stub).to have_been_requested
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.first.id).to eq("<PREFIX_ID:1>")
    end

    it "passes query params to received" do
      stub = ApiCorpus.stub!("Vouches_received")

      vouches.received(claim: "identity_verified")
      expect(stub.with(query: { claim: "identity_verified" })).to have_been_requested
    end
  end
end
