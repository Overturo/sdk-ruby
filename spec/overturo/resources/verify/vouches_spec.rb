# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Verify::Vouches do
  let(:client) { test_client }
  let(:vouches) { client.verify.vouches }

  describe "#create" do
    it "creates a vouch" do
      stub = stub_request(:post, "https://overturo.com/api/v1/vouches")
             .with(body: '{"subject_id":"usr_2","claim":"identity_verified"}')
             .to_return(
               status: 201,
               body: '{"vouch":{"id":"vch_1","subject_id":"usr_2","claim":"identity_verified"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = vouches.create(subject_id: "usr_2", claim: "identity_verified")
      expect(stub).to have_been_requested
      expect(result.id).to eq("vch_1")
    end
  end

  describe "#list" do
    it "lists vouches" do
      stub_api(:get, "/vouches", body: {
                 "vouches" => [{ "id" => "vch_1" }, { "id" => "vch_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = vouches.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#received" do
    it "sends GET to /vouches/received and returns a ListObject" do
      stub = stub_request(:get, "https://overturo.com/api/v1/vouches/received")
             .to_return(
               status: 200,
               body: '{"vouches":[{"id":"vch_3","from":"usr_2"},{"id":"vch_4","from":"usr_3"}],"pagination":{"page":1,"per_page":25,"total":2}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = vouches.received
      expect(stub).to have_been_requested
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
      expect(result.data.first.id).to eq("vch_3")
    end

    it "passes query params to received" do
      stub = stub_request(:get, "https://overturo.com/api/v1/vouches/received?claim=identity_verified")
             .to_return(
               status: 200,
               body: '{"vouches":[{"id":"vch_3"}],"pagination":{"page":1,"per_page":25,"total":1}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = vouches.received(claim: "identity_verified")
      expect(stub).to have_been_requested
      expect(result.data.size).to eq(1)
    end
  end
end
