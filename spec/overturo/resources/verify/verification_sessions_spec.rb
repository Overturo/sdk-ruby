# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Verify::VerificationSessions do
  let(:client) { test_client }
  let(:sessions) { client.verify.verification_sessions }

  describe "#create" do
    it "creates a verification session" do
      stub = stub_request(:post, "https://overturo.com/api/v1/verification_sessions")
             .with(body: '{"provider":"jumio","user_id":"usr_1"}')
             .to_return(
               status: 201,
               body: '{"verification_session":{"id":"vs_1","status":"pending"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = sessions.create(provider: "jumio", user_id: "usr_1")
      expect(stub).to have_been_requested
      expect(result.id).to eq("vs_1")
      expect(result.status).to eq("pending")
    end
  end

  describe "#retrieve" do
    it "retrieves a verification session" do
      stub_api(:get, "/verification_sessions/vs_1", body: {
                 "verification_session" => { "id" => "vs_1", "status" => "completed" }
               })

      result = sessions.retrieve("vs_1")
      expect(result.status).to eq("completed")
    end
  end
end
