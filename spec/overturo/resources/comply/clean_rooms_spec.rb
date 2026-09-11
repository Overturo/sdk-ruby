# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Comply::CleanRooms do
  let(:client) { test_client }
  let(:clean_rooms) { client.comply.clean_rooms }

  describe "#create" do
    it "creates a clean room" do
      stub = stub_request(:post, "https://overturo.com/api/v1/clean_rooms")
             .with(body: '{"name":"Analytics Room","participants":["org_1","org_2"]}')
             .to_return(
               status: 201,
               body: '{"clean_room":{"id":"cr_1","name":"Analytics Room","status":"pending_approval"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = clean_rooms.create(name: "Analytics Room", participants: %w[org_1 org_2])
      expect(stub).to have_been_requested
      expect(result.id).to eq("cr_1")
      expect(result.status).to eq("pending_approval")
    end
  end

  describe "#list" do
    it "lists clean rooms" do
      stub_api(:get, "/clean_rooms", body: {
                 "clean_rooms" => [{ "id" => "cr_1" }, { "id" => "cr_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = clean_rooms.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#approve" do
    it "sends POST to approve" do
      stub = stub_request(:post, "https://overturo.com/api/v1/clean_rooms/cr_1/approve")
             .to_return(
               status: 200,
               body: '{"clean_room":{"id":"cr_1","status":"approved","approved_at":"2026-03-09T00:00:00Z"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = clean_rooms.approve("cr_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("approved")
      expect(result.approved_at).to eq("2026-03-09T00:00:00Z")
    end
  end

  # 126-SX-5 — compute-to-data: the result surfaces its privacy parameters and a
  # first-class `suppressed` flag (a full suppression is never a silent empty).
  describe "#run_query" do
    it "runs a query and surfaces the privacy parameters + result" do
      stub = stub_request(:post, "https://overturo.com/api/v1/clean_rooms/cr_1/queries")
             .to_return(
               status: 200,
               body: '{"status":"completed","suppressed":false,"k_anonymity_met":true,"result_data":{"count":42}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = clean_rooms.run_query("cr_1", query: { aggregate: "count" })
      expect(stub).to have_been_requested
      expect(result.status).to eq("completed")
      expect(result.suppressed).to be(false)
      expect(result.k_anonymity_met).to be(true)
    end

    it "surfaces a full suppression as a first-class state" do
      stub_request(:post, "https://overturo.com/api/v1/clean_rooms/cr_1/queries")
        .to_return(
          status: 200,
          body: '{"status":"suppressed","suppressed":true,"suppression_reason":"all groups < k"}',
          headers: { "Content-Type" => "application/json" }
        )

      result = clean_rooms.run_query("cr_1", query: { aggregate: "count" })
      expect(result.status).to eq("suppressed")
      expect(result.suppressed).to be(true)
      expect(result.suppression_reason).to eq("all groups < k")
    end
  end
end
