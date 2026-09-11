# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Protect::DataLicenses do
  let(:client) { test_client }
  let(:data_licenses) { client.protect.data_licenses }

  describe "#create" do
    it "creates a data license" do
      stub = stub_request(:post, "https://overturo.com/api/v1/data_licenses")
             .with(body: '{"licensee_id":"app_2","scope":"analytics"}')
             .to_return(
               status: 201,
               body: '{"data_license":{"id":"dl_1","status":"active"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = data_licenses.create(licensee_id: "app_2", scope: "analytics")
      expect(stub).to have_been_requested
      expect(result.id).to eq("dl_1")
    end
  end

  describe "#list" do
    it "lists data licenses" do
      stub_api(:get, "/data_licenses", body: {
                 "data_licenses" => [{ "id" => "dl_1" }, { "id" => "dl_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = data_licenses.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#terminate" do
    it "sends POST to terminate with reason" do
      stub = stub_request(:post, "https://overturo.com/api/v1/data_licenses/dl_1/terminate")
             .with(body: '{"reason":"contract_expired"}')
             .to_return(
               status: 200,
               body: '{"data_license":{"id":"dl_1","status":"terminated"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = data_licenses.terminate("dl_1", reason: "contract_expired")
      expect(stub).to have_been_requested
      expect(result.status).to eq("terminated")
    end
  end
end
