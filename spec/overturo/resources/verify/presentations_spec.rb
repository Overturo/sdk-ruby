# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Verify::Presentations do
  let(:client) { test_client }
  let(:presentations) { client.verify.presentations }

  describe "#create" do
    it "creates a presentation" do
      stub = stub_request(:post, "https://overturo.com/api/v1/presentations")
             .with(body: '{"credential_id":"cred_1","verifier_id":"ver_1"}')
             .to_return(
               status: 201,
               body: '{"presentation":{"id":"pres_1","status":"pending"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = presentations.create(credential_id: "cred_1", verifier_id: "ver_1")
      expect(stub).to have_been_requested
      expect(result.id).to eq("pres_1")
      expect(result.status).to eq("pending")
    end
  end

  describe "#present" do
    it "sends PATCH to present (the API declares the present action as an update) and returns raw response" do
      stub = stub_request(:patch, "https://overturo.com/api/v1/presentations/pres_1/present")
             .with(body: '{"disclosed_claims":["name","email"]}')
             .to_return(
               status: 200,
               body: '{"verified":true,"claims":{"name":"Test User","email":"test@example.com"},"verifier":"ver_1"}',
               headers: { "Content-Type" => "application/json" }
             )

      result = presentations.present("pres_1", disclosed_claims: %w[name email])
      expect(stub).to have_been_requested
      expect(result.verified).to be true
      expect(result.claims.name).to eq("Test User")
      expect(result.verifier).to eq("ver_1")
    end
  end
end
