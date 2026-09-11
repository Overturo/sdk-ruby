# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Consent::ConsentSessions do
  let(:client) { test_client }
  let(:sessions) { client.consent.consent_sessions }

  describe "#create" do
    it "creates a consent session" do
      stub = stub_request(:post, "https://overturo.com/api/v1/consent_sessions")
             .with(body: '{"flow_id":"flow_123","delivery_mode":"redirect"}')
             .to_return(
               status: 201,
               body: '{"consent_session":{"id":"cs_1","session_token":"tok_abc"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = sessions.create(flow_id: "flow_123", delivery_mode: "redirect")
      expect(stub).to have_been_requested
      expect(result.id).to eq("cs_1")
      expect(result.session_token).to eq("tok_abc")
    end
  end

  describe "#authorize" do
    it "authorizes a consent session" do
      stub_request(:post, "https://overturo.com/api/v1/consent_sessions/cs_1/authorize")
        .to_return(
          status: 200,
          body: '{"consent_session":{"id":"cs_1","status":"authorized"}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = sessions.authorize("cs_1")
      expect(result.status).to eq("authorized")
    end
  end

  describe "#verify" do
    it "verifies a consent token after the user completes a flow" do
      stub_request(:get, "https://overturo.com/api/v1/consent_sessions/cs_1/verify")
        .with(query: { consent_token: "ct_abc" })
        .to_return(
          status: 200,
          body: '{"valid":true,"status":"fulfilled","accord_id":"flw_xyz"}',
          headers: { "Content-Type" => "application/json" }
        )

      result = sessions.verify("cs_1", consent_token: "ct_abc")
      expect(result.valid).to be true
      expect(result.status).to eq("fulfilled")
    end
  end

  describe "#exchange" do
    it "exchanges a consent session token" do
      stub_request(:post, "https://overturo.com/api/v1/consent_sessions/cs_1/exchange")
        .to_return(
          status: 200,
          body: '{"access_token":"at_123","token_type":"bearer"}',
          headers: { "Content-Type" => "application/json" }
        )

      result = sessions.exchange("cs_1")
      expect(result.access_token).to eq("at_123")
    end

    it "retries on 202 and succeeds on 200" do
      stub = stub_request(:post, "https://overturo.com/api/v1/consent_sessions/cs_1/exchange")
             .to_return(
               { status: 202, body: '{"status":"pending","message":"Fulfillment in progress"}',
                 headers: { "Content-Type" => "application/json" } },
               { status: 200, body: '{"access_token":"at_123","claims":{"email":"user@example.com"}}',
                 headers: { "Content-Type" => "application/json" } }
             )

      allow(sessions).to receive(:sleep)
      result = sessions.exchange("cs_1", consent_token: "ct_abc")

      expect(stub).to have_been_requested.times(2)
      expect(result.access_token).to eq("at_123")
      expect(sessions).to have_received(:sleep).with(1).once
    end

    it "raises after max retries on persistent 202" do
      stub_request(:post, "https://overturo.com/api/v1/consent_sessions/cs_1/exchange")
        .to_return(
          status: 202,
          body: '{"status":"pending","message":"Fulfillment in progress"}',
          headers: { "Content-Type" => "application/json" }
        )

      allow(sessions).to receive(:sleep)

      expect { sessions.exchange("cs_1") }.to raise_error(Overturo::ApiError, /fulfillment still pending/)
    end
  end
end
