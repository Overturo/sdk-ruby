# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Verify::Credentials do
  let(:client) { test_client }
  let(:creds) { client.verify.credentials }

  describe "#create" do
    it "creates a credential" do
      stub = stub_request(:post, "https://overturo.com/api/v1/credentials")
             .to_return(
               status: 201,
               body: '{"credential":{"id":"cred_1","type":"identity"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = creds.create(type: "identity")
      expect(stub).to have_been_requested
      expect(result.id).to eq("cred_1")
    end
  end

  describe "#list" do
    it "lists credentials" do
      stub_api(:get, "/credentials", body: {
                 "credentials" => [{ "id" => "cred_1" }, { "id" => "cred_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = creds.list
      expect(result.data.size).to eq(2)
    end
  end

  describe "#retrieve" do
    it "retrieves a credential" do
      stub_api(:get, "/credentials/cred_1", body: { "credential" => { "id" => "cred_1", "status" => "active" } })

      result = creds.retrieve("cred_1")
      expect(result.status).to eq("active")
    end
  end
end
