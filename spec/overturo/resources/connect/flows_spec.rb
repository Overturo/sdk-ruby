# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Connect::Flows do
  let(:client) { test_client }
  let(:flows) { client.connect.flows }
  let(:application_id) { "app_abc" }

  describe "#create" do
    it "creates a flow under an application" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/#{application_id}/flows")
             .with(body: '{"name":"Data Collection","type":"consent"}')
             .to_return(
               status: 201,
               body: '{"flow":{"id":"flw_1","name":"Data Collection","status":"draft"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = flows.create(application_id, name: "Data Collection", type: "consent")
      expect(stub).to have_been_requested
      expect(result.id).to eq("flw_1")
      expect(result.status).to eq("draft")
    end
  end

  describe "#retrieve" do
    it "fetches a flow by id under an application" do
      stub_api(:get, "/applications/#{application_id}/flows/flw_1", body: { flow: { id: "flw_1", status: "active" } })

      result = flows.retrieve(application_id, "flw_1")
      expect(result.id).to eq("flw_1")
      expect(result.status).to eq("active")
    end
  end

  describe "#list" do
    it "lists flows under an application with pagination" do
      stub_api(:get, "/applications/#{application_id}/flows", body: {
                 "flows" => [{ "id" => "flw_1" }, { "id" => "flw_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = flows.list(application_id)
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
    end
  end

  describe "#update" do
    it "patches a flow under an application" do
      stub = stub_request(:patch, "https://overturo.com/api/v1/applications/#{application_id}/flows/flw_1")
             .with(body: '{"name":"Renamed"}')
             .to_return(
               status: 200,
               body: '{"flow":{"id":"flw_1","name":"Renamed"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = flows.update(application_id, "flw_1", name: "Renamed")
      expect(stub).to have_been_requested
      expect(result.name).to eq("Renamed")
    end
  end

  describe "#delete" do
    it "deletes a flow under an application" do
      stub_api(:delete, "/applications/#{application_id}/flows/flw_1", body: { flow: { id: "flw_1", status: "deleted" } })

      result = flows.delete(application_id, "flw_1")
      expect(result.id).to eq("flw_1")
    end
  end

  describe "#activate" do
    it "POSTs to the activate member action" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/#{application_id}/flows/flw_1/activate")
             .to_return(
               status: 200,
               body: '{"flow":{"id":"flw_1","status":"active"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = flows.activate(application_id, "flw_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("active")
    end
  end

  describe "#deprecate" do
    it "POSTs to the deprecate member action with successor" do
      stub = stub_request(:post, "https://overturo.com/api/v1/applications/#{application_id}/flows/flw_1/deprecate")
             .with(body: '{"successor_id":"flw_2"}')
             .to_return(
               status: 200,
               body: '{"flow":{"id":"flw_1","status":"deprecated"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = flows.deprecate(application_id, "flw_1", successor_id: "flw_2")
      expect(stub).to have_been_requested
      expect(result.status).to eq("deprecated")
    end
  end

  describe "#archive" do
    it "POSTs to the archive member action" do
      stub_api(:post, "/applications/#{application_id}/flows/flw_1/archive", body: { flow: { id: "flw_1", status: "archived" } })

      result = flows.archive(application_id, "flw_1")
      expect(result.status).to eq("archived")
    end
  end

  describe "error handling" do
    it "raises InvalidRequestError when activating a non-draft flow" do
      stub_api(:post, "/applications/#{application_id}/flows/flw_1/activate", status: 422, body: { error: "Flow must be in draft status to activate" })

      expect { flows.activate(application_id, "flw_1") }
        .to raise_error(Overturo::InvalidRequestError, "Flow must be in draft status to activate")
    end
  end
end
