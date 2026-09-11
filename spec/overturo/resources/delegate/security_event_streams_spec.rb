# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Delegate::SecurityEventStreams do
  let(:client) { test_client }
  let(:streams) { client.delegate_ns.security_event_streams }

  describe "#create" do
    it "creates a security event stream" do
      stub = stub_request(:post, "https://overturo.com/api/v1/security_event_streams")
             .with(body: '{"endpoint_url":"https://example.com/events","events":["credential.revoked"]}')
             .to_return(
               status: 201,
               body: '{"security_event_stream":{"id":"ses_1","status":"active"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = streams.create(endpoint_url: "https://example.com/events", events: ["credential.revoked"])
      expect(stub).to have_been_requested
      expect(result.id).to eq("ses_1")
    end
  end

  describe "#list" do
    it "lists security event streams" do
      stub_api(:get, "/security_event_streams", body: {
                 "security_event_streams" => [{ "id" => "ses_1" }, { "id" => "ses_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = streams.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#verify" do
    it "sends POST to verify and returns raw response" do
      stub = stub_request(:post, "https://overturo.com/api/v1/security_event_streams/ses_1/verify")
             .to_return(
               status: 200,
               body: '{"valid":true,"endpoint_status":"reachable","last_delivery_at":"2026-03-09T00:00:00Z"}',
               headers: { "Content-Type" => "application/json" }
             )

      result = streams.verify("ses_1")
      expect(stub).to have_been_requested
      expect(result.valid).to be true
      expect(result.endpoint_status).to eq("reachable")
      expect(result.last_delivery_at).to eq("2026-03-09T00:00:00Z")
    end
  end

  describe "#poll" do
    it "sends GET to poll and returns raw response with events" do
      stub = stub_request(:get, "https://overturo.com/api/v1/security_event_streams/ses_1/poll")
             .to_return(
               status: 200,
               body: '{"events":[{"id":"evt_1","type":"credential.revoked"},{"id":"evt_2","type":"delegation.suspended"}],"cursor":"cur_abc"}',
               headers: { "Content-Type" => "application/json" }
             )

      result = streams.poll("ses_1")
      expect(stub).to have_been_requested
      expect(result.cursor).to eq("cur_abc")
      expect(result.events.size).to eq(2)
      expect(result.events.first.type).to eq("credential.revoked")
    end

    it "forwards query params to poll" do
      stub = stub_request(:get, "https://overturo.com/api/v1/security_event_streams/ses_1/poll?cursor=cur_abc&limit=10")
             .to_return(
               status: 200,
               body: '{"events":[],"cursor":"cur_abc"}',
               headers: { "Content-Type" => "application/json" }
             )

      streams.poll("ses_1", cursor: "cur_abc", limit: 10)
      expect(stub).to have_been_requested
    end
  end
end
