# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Verify::TrustScores do
  let(:client) { test_client }
  let(:trust_scores) { client.verify.trust_scores }

  describe "#list" do
    it "lists trust scores" do
      stub_api(:get, "/trust_scores", body: {
                 "trust_scores" => [{ "id" => "ts_1", "score" => 0.85 }, { "id" => "ts_2", "score" => 0.72 }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = trust_scores.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#query" do
    it "sends POST to collection query endpoint with params" do
      stub = stub_request(:post, "https://overturo.com/api/v1/trust_scores/query")
             .with(body: '{"subject":"usr_1","context":"data_sharing"}')
             .to_return(
               status: 200,
               body: '{"trust_score":{"id":"ts_1","score":0.85,"subject":"usr_1","context":"data_sharing"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = trust_scores.query(subject: "usr_1", context: "data_sharing")
      expect(stub).to have_been_requested
      expect(result.score).to eq(0.85)
      expect(result.subject).to eq("usr_1")
    end
  end
end
