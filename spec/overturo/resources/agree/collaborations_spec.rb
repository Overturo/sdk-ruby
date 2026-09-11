# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Agree::Collaborations do
  let(:client) { test_client }
  let(:collaborations) { client.agree.collaborations }

  describe "#create" do
    it "creates a collaboration" do
      stub = stub_request(:post, "https://overturo.com/api/v1/collaborations")
             .with(body: '{"title":"Joint Research","parties":["org_1","org_2"]}')
             .to_return(
               status: 201,
               body: '{"collaboration":{"id":"collab_1","title":"Joint Research","status":"draft"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = collaborations.create(title: "Joint Research", parties: %w[org_1 org_2])
      expect(stub).to have_been_requested
      expect(result.id).to eq("collab_1")
      expect(result.status).to eq("draft")
    end
  end

  describe "#list" do
    it "lists collaborations" do
      stub_api(:get, "/collaborations", body: {
                 "collaborations" => [{ "id" => "collab_1" }, { "id" => "collab_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = collaborations.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#invite" do
    it "sends POST to invite and returns raw response" do
      stub = stub_request(:post, "https://overturo.com/api/v1/collaborations/collab_1/invite")
             .with(body: '{"email":"partner@example.com","role":"contributor"}')
             .to_return(
               status: 200,
               body: '{"invited":true,"invite_url":"https://example.com/invite/abc","expires_at":"2026-03-16T00:00:00Z"}',
               headers: { "Content-Type" => "application/json" }
             )

      result = collaborations.invite("collab_1", email: "partner@example.com", role: "contributor")
      expect(stub).to have_been_requested
      expect(result.invited).to be true
      expect(result.invite_url).to eq("https://example.com/invite/abc")
    end
  end

  describe "#sign" do
    it "sends POST to sign" do
      stub = stub_request(:post, "https://overturo.com/api/v1/collaborations/collab_1/sign")
             .to_return(
               status: 200,
               body: '{"collaboration":{"id":"collab_1","status":"signed","signed_at":"2026-03-09T00:00:00Z"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = collaborations.sign("collab_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("signed")
      expect(result.signed_at).to eq("2026-03-09T00:00:00Z")
    end
  end
end
