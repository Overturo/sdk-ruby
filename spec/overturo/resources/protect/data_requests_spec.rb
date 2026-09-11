# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Protect::DataRequests do
  let(:client) { test_client }
  let(:data_requests) { client.protect.data_requests }

  describe "#create" do
    it "creates a data request" do
      stub = stub_request(:post, "https://overturo.com/api/v1/data_requests")
             .with(body: '{"type":"access","subject_id":"usr_1"}')
             .to_return(
               status: 201,
               body: '{"data_request":{"id":"dr_1","type":"access","status":"pending"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = data_requests.create(type: "access", subject_id: "usr_1")
      expect(stub).to have_been_requested
      expect(result.id).to eq("dr_1")
      expect(result.status).to eq("pending")
    end
  end

  describe "#retrieve" do
    it "retrieves a data request" do
      stub_api(:get, "/data_requests/dr_1", body: {
                 "data_request" => { "id" => "dr_1", "type" => "access", "status" => "pending" }
               })

      result = data_requests.retrieve("dr_1")
      expect(result.id).to eq("dr_1")
      expect(result.type).to eq("access")
    end
  end

  describe "#list" do
    it "lists data requests with pagination" do
      stub_api(:get, "/data_requests", body: {
                 "data_requests" => [{ "id" => "dr_1" }, { "id" => "dr_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = data_requests.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
      expect(result.pagination["total"]).to eq(2)
    end
  end
end
