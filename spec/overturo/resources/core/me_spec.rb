# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Core::Me do
  let(:client) { test_client }
  let(:me) { client.core.me }

  describe "#retrieve" do
    it "sends GET to /me with no ID parameter and reads the bare user document" do
      stub = ApiCorpus.stub!("Me_show")

      result = me.retrieve
      expect(stub).to have_been_requested
      expect(result.id).to eq(ApiCorpus.body("Me_show")["id"])
      expect(result.name).to eq("Corpus Owner")
    end

    it "raises AuthenticationError for invalid API key" do
      stub_api(:get, "/me", status: 401, body: { error: "Invalid API key" })

      expect { me.retrieve }.to raise_error(Overturo::AuthenticationError)
    end
  end
end
