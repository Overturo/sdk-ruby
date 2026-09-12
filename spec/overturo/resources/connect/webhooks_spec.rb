# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Connect::Webhooks do
  let(:client) { test_client }
  let(:webhooks) { client.connect.webhooks }
  let(:create_params) { ApiCorpus.request("Applications_Webhooks_create")["body"] }

  describe "#create" do
    it "creates a webhook nested under an application, sending the payload the API accepted" do
      stub = ApiCorpus.stub!("Applications_Webhooks_create", with_body: true)

      result = webhooks.create("app_123", create_params)
      expect(stub).to have_been_requested
      expect(result.id).to eq("<PREFIX_ID:2>")
      expect(result.url).to eq(create_params.dig("webhook_subscription", "url"))
      expect(result.enabled).to be(true)
    end
  end

  describe "#list" do
    it "lists webhooks for an application" do
      ApiCorpus.stub!("Applications_Webhooks_index")

      result = webhooks.list("app_123")
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(1)
      expect(result.data.first.id).to eq("<PREFIX_ID:2>")
    end
  end

  describe "#retrieve" do
    it "retrieves a specific webhook" do
      ApiCorpus.stub!("Applications_Webhooks_show")

      result = webhooks.retrieve("app_123", "wh_1")
      expect(result.id).to eq("<PREFIX_ID:2>")
      expect(result.url).to eq("https://example.com/hooks/corpus")
    end
  end

  describe "#update" do
    it "updates a webhook" do
      stub = ApiCorpus.stub!("Applications_Webhooks_update", with_body: true)

      result = webhooks.update("app_123", "wh_1", ApiCorpus.request("Applications_Webhooks_update")["body"])
      expect(stub).to have_been_requested
      expect(result.enabled).to be(false)
    end
  end

  describe "#delete" do
    it "deletes a webhook (204, empty body)" do
      stub = ApiCorpus.stub!("Applications_Webhooks_destroy")

      result = webhooks.delete("app_123", "wh_1")
      expect(stub).to have_been_requested
      expect(a_request(:delete, %r{/applications/app_123/webhooks/wh_1\z}).with(body: "")).to have_been_made
      expect(result.to_h).to eq({})
    end
  end
end
