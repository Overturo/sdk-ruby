# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Consent::TrustLevels do
  let(:client) { test_client }
  let(:trust_levels) { client.consent.trust_levels }

  describe "#list" do
    it "lists trust levels" do
      stub_api(:get, "/trust_levels", body: {
                 "trust_levels" => [{ "id" => "tl_1", "level" => 1 }, { "id" => "tl_2", "level" => 2 }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = trust_levels.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#trigger" do
    it "sends POST to trigger with params" do
      stub = stub_request(:post, "https://overturo.com/api/v1/trust_levels/tl_1/trigger")
             .with(body: '{"user_id":"usr_1"}')
             .to_return(
               status: 200,
               body: '{"trust_level":{"id":"tl_1","level":2,"triggered":true}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = trust_levels.trigger("tl_1", user_id: "usr_1")
      expect(stub).to have_been_requested
      expect(result.triggered).to be true
      expect(result.level).to eq(2)
    end
  end
end
