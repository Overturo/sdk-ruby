# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Connect::Portability do
  let(:client) { test_client }
  let(:portability) { client.connect.portability }

  describe "#formats" do
    it "reads the supported portability formats for an application" do
      stub_request(:get, "https://overturo.com/api/v1/applications/app_1/portability/formats")
        .to_return(
          status: 200,
          body: '{"supported_export_formats":["json"],"supported_import_formats":["json"]}',
          headers: { "Content-Type" => "application/json" }
        )

      result = portability.formats("app_1")
      expect(result.supported_export_formats).to eq(["json"])
    end
  end

  describe "#confirm_export" do
    it "confirms and forwards a portability export" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/app_1/portability/confirm_export")
             .with(body: '{"portability_transfer_id":"pt_1","source_hash":"abc"}')
             .to_return(
               status: 200,
               body: '{"portability_transfer":{"id":"pt_1","status":"forwarded"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = portability.confirm_export("app_1", portability_transfer_id: "pt_1", source_hash: "abc")
      expect(stub).to have_been_requested
      expect(result.portability_transfer["status"]).to eq("forwarded")
    end
  end

  describe "#confirm_import" do
    it "confirms receipt of a portability import" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/app_1/portability/confirm_import")
             .with(body: '{"portability_transfer_id":"pt_1","destination_hash":"def"}')
             .to_return(
               status: 200,
               body: '{"portability_transfer":{"id":"pt_1","status":"received"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = portability.confirm_import("app_1", portability_transfer_id: "pt_1", destination_hash: "def")
      expect(stub).to have_been_requested
      expect(result.portability_transfer["status"]).to eq("received")
    end
  end
end
