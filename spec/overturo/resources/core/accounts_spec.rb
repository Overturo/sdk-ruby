# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Core::Accounts do
  let(:client) { test_client }
  let(:accounts) { client.core.accounts }

  describe "#list" do
    it "lists accounts with pagination" do
      stub_api(:get, "/accounts", body: {
                 "accounts" => [{ "id" => "acct_1" }, { "id" => "acct_2" }],
                 "pagination" => { "page" => 1, "per_page" => 25, "total" => 2 }
               })

      result = accounts.list
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(2)
      expect(result.pagination["total"]).to eq(2)
    end
  end

  # NOTE: Create / Retrieve / Update / Delete are intentionally not implemented —
  # the accounts API is list-only. Account creation goes through the dashboard
  # signup flow.
  describe "removed methods" do
    it "does not respond to create" do
      expect(accounts).not_to respond_to(:create)
    end

    it "does not respond to retrieve" do
      expect(accounts).not_to respond_to(:retrieve)
    end

    it "does not respond to update" do
      expect(accounts).not_to respond_to(:update)
    end

    it "does not respond to delete" do
      expect(accounts).not_to respond_to(:delete)
    end
  end
end
