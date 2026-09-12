# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Core::Accounts do
  let(:client) { test_client }
  let(:accounts) { client.core.accounts }

  describe "#list" do
    it "lists the caller's accounts (the API renders a bare collection)" do
      stub = ApiCorpus.stub!("Accounts_index")

      result = accounts.list
      expect(stub).to have_been_requested
      expect(result).to be_a(Overturo::ListObject)
      expect(result.data.size).to eq(ApiCorpus.body("Accounts_index").size)
      expect(result.data.first.name).to eq("Corpus Owner")
      expect(result.more?).to be(false)
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
