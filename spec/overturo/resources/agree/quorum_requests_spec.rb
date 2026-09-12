# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Agree::QuorumRequests do
  let(:client) { test_client }
  let(:quorum_requests) { client.agree.quorum_requests }

  describe "#create" do
    it "creates a quorum request, sending the payload the API accepted" do
      stub = ApiCorpus.stub!("QuorumRequests_create", with_body: true)

      result = quorum_requests.create(ApiCorpus.request("QuorumRequests_create")["body"])
      expect(stub).to have_been_requested
      expect(result.id).to eq("<PREFIX_ID:2>")
      expect(result.status).to eq("voting")
    end
  end

  describe "#list" do
    it "lists quorum requests" do
      ApiCorpus.stub!("QuorumRequests_index")

      result = quorum_requests.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(1)
    end
  end

  describe "#retrieve" do
    it "reads one quorum request" do
      ApiCorpus.stub!("QuorumRequests_show")

      expect(quorum_requests.retrieve("qreq_1").status).to eq("voting")
    end
  end

  describe "#vote" do
    it "sends POST to vote with the payload the API accepts and returns the updated request" do
      stub = ApiCorpus.stub!("QuorumRequests_vote", with_body: true)

      result = quorum_requests.vote("qreq_1", ApiCorpus.request("QuorumRequests_vote")["body"])
      expect(stub).to have_been_requested
      expect(result.id).to eq("<PREFIX_ID:1>")
      expect(result.approval_count).to be_a(Integer)
    end
  end
end
