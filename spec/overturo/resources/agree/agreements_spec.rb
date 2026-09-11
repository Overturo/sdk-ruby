# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Agree::Agreements do
  let(:client) { test_client }
  let(:agreements) { client.agree.agreements }

  describe "#list" do
    it "lists agreements" do
      stub_api(:get, "/agreements", body: {
                 "agreements" => [{ "id" => "agr_1" }, { "id" => "agr_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = agreements.list
      expect(result.data.size).to eq(2)
    end
  end

  describe "#propose" do
    it "proposes an agreement" do
      stub = stub_request(:post, "https://overturo.com/api/v1/agreements/propose")
             .with(body: '{"title":"Data sharing","counterparty_id":"usr_2"}')
             .to_return(
               status: 201,
               body: '{"agreement":{"id":"agr_1","status":"offered"}}',
               headers: { "Content-Type" => "application/json" }
             )

      result = agreements.propose(title: "Data sharing", counterparty_id: "usr_2")
      expect(stub).to have_been_requested
      expect(result.status).to eq("offered")
    end
  end

  describe "#accept" do
    it "accepts an agreement" do
      stub_request(:post, "https://overturo.com/api/v1/agreements/agr_1/accept")
        .to_return(
          status: 200,
          body: '{"agreement":{"id":"agr_1","status":"accepted"}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = agreements.accept("agr_1")
      expect(result.status).to eq("accepted")
    end
  end

  describe "#counter" do
    it "counters an agreement" do
      stub_request(:post, "https://overturo.com/api/v1/agreements/agr_1/counter")
        .with(body: '{"terms":"revised terms"}')
        .to_return(
          status: 200,
          body: '{"agreement":{"id":"agr_1","status":"countered"}}',
          headers: { "Content-Type" => "application/json" }
        )

      result = agreements.counter("agr_1", terms: "revised terms")
      expect(result.status).to eq("countered")
    end
  end
end
