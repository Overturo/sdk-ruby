# frozen_string_literal: true

require "webmock/rspec"
require "json"
require_relative "../lib/overturo"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.order = :random
end

def stub_api(method, path, status: 200, body: {}, query: nil)
  stub = stub_request(method, "https://overturo.com/api/v1#{path}")
  stub = stub.with(query: query) if query
  stub.to_return(
    status: status,
    body: body.to_json,
    headers: { "Content-Type" => "application/json" }
  )
end

def test_client
  Overturo::Client.new(api_key: "sk_test_123")
end
