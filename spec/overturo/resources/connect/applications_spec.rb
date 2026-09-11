# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Connect::Applications do
  let(:client) { test_client }
  let(:apps) { client.connect.applications }

  describe "#publish" do
    it "sends POST to publish" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/app_123/publish")
             .to_return(
               status: 200,
               body: '{"application":{"id":"app_123","published":true}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = apps.publish("app_123")
      expect(stub).to have_been_requested
      expect(result.published).to be true
    end
  end

  describe "#unpublish" do
    it "sends POST to unpublish" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/app_123/unpublish")
             .to_return(
               status: 200,
               body: '{"application":{"id":"app_123","published":false}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = apps.unpublish("app_123")
      expect(stub).to have_been_requested
      expect(result.published).to be false
    end
  end
end
