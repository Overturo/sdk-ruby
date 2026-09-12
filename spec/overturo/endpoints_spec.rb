# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe Overturo::Endpoints do
  let(:committed) { JSON.parse(File.read(File.expand_path("../../endpoints.json", __dir__))) }

  it "matches the committed endpoints.json (bundle exec rake endpoints:write to refresh)" do
    expect(committed["endpoints"]).to eq(described_class.manifest)
  end

  it "covers every resource class, with no unexpanded template tokens" do
    expect(described_class.manifest.map { |e| e["resource"] }.uniq.size).to eq(described_class.resource_classes.size)
    expect(described_class.manifest.map { |e| e["path"] }.grep(/%\{/)).to eq([])
  end

  it "declares the endpoints built by explicit http_client calls" do
    paths = described_class.manifest.map { |e| "#{e["method"]} #{e["path"]}" }
    expect(paths).to include("GET /api/v1/me", "GET /api/v1/vouches/received", "DELETE /api/v1/delegations/{id}/revoke",
                             "POST /api/v1/applications/{application_id}/flows/{id}/activate", "GET /api/v1/clean_rooms/{id}/queries/{query_id}")
  end
end
