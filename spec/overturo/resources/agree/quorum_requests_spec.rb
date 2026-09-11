# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Agree::QuorumRequests do
  let(:client) { test_client }
  let(:quorum_requests) { client.agree.quorum_requests }

  describe "#create" do
    it "creates a quorum request" do
      stub = stub_request(:post, "https://overturo.com/api/v1/quorum_requests")
             .with(body: '{"agreement_id":"agr_1","action_type":"fund_release"}')
             .to_return(
               status: 201,
               body: '{"quorum_request":{"id":"qreq_1","status":"voting"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = quorum_requests.create(agreement_id: "agr_1", action_type: "fund_release")
      expect(stub).to have_been_requested
      expect(result.id).to eq("qreq_1")
      expect(result.status).to eq("voting")
    end
  end

  describe "#list" do
    it "lists quorum requests" do
      stub_api(:get, "/quorum_requests", body: {
                 "quorum_requests" => [{ "id" => "qreq_1" }, { "id" => "qreq_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = quorum_requests.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#vote" do
    it "sends POST to vote with choice" do
      stub = stub_request(:post, "https://overturo.com/api/v1/quorum_requests/qreq_1/vote")
             .with(body: '{"choice":"approve","comment":"Looks good"}')
             .to_return(
               status: 200,
               body: '{"quorum_request":{"id":"qreq_1","vote":"approve","voted_at":"2026-03-09T00:00:00Z"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = quorum_requests.vote("qreq_1", choice: "approve", comment: "Looks good")
      expect(stub).to have_been_requested
      expect(result.vote).to eq("approve")
    end
  end
end
