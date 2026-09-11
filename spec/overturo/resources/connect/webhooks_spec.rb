# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Connect::Webhooks do
  let(:client) { test_client }
  let(:webhooks) { client.connect.webhooks }

  describe "#create" do
    it "creates a webhook nested under an application" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/app_123/webhooks")
             .with(body: '{"url":"https://example.com/hook","events":["policy.activated"]}')
             .to_return(
               status: 201,
               body: '{"webhook":{"id":"wh_1","url":"https://example.com/hook"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = webhooks.create("app_123", url: "https://example.com/hook", events: ["policy.activated"])
      expect(stub).to have_been_requested
      expect(result.id).to eq("wh_1")
    end
  end

  describe "#list" do
    it "lists webhooks for an application" do
      stub_request(:get, "https://overturo.com/api/v1/applications/app_123/webhooks")
        .to_return(
          status: 200,
          body: '{"webhooks":[{"id":"wh_1"},{"id":"wh_2"}],"pagination":{"page":1,"per_page":25,"total":2}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = webhooks.list("app_123")
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#retrieve" do
    it "retrieves a specific webhook" do
      stub_request(:get, "https://overturo.com/api/v1/applications/app_123/webhooks/wh_1")
        .to_return(
          status: 200,
          body: '{"webhook":{"id":"wh_1","url":"https://example.com/hook"}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = webhooks.retrieve("app_123", "wh_1")
      expect(result.id).to eq("wh_1")
    end
  end

  describe "#delete" do
    it "deletes a webhook" do
      stub = stub_request(:delete, "https://overturo.com/api/v1/applications/app_123/webhooks/wh_1")
             .to_return(
               status: 200,
               body: '{"webhook":{"id":"wh_1","deleted":true}}',
               headers: { "Content-Type" => "application/json" }
             )

      webhooks.delete("app_123", "wh_1")
      expect(stub).to have_been_requested
    end
  end
end
