# frozen_string_literal: true

require_relative "lib/overturo/version"

Gem::Specification.new do |spec|
  spec.name = "overturo"
  spec.version = Overturo::VERSION
  spec.authors = ["Overturo"]
  spec.email = ["dev@overturo.com"]

  spec.summary = "Ruby client for the Overturo API"
  spec.description = "Server-side Ruby SDK for the Overturo personal data platform. " \
                     "Covers all 7 product surfaces (Connect, Consent, Verify, Protect, Agree, Delegate, Comply) " \
                     "with Bearer token authentication."
  spec.homepage = "https://github.com/overturo/sdk-ruby"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir["lib/**/*.rb", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  # Zero runtime dependencies — stdlib only (Net::HTTP, JSON, URI)
  # Dev dependencies specified in Gemfile

  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = "https://github.com/overturo/sdk-ruby"
  spec.metadata["bug_tracker_uri"] = "https://github.com/overturo/sdk-ruby/issues"
  spec.metadata["changelog_uri"] = "https://github.com/overturo/sdk-ruby/blob/main/CHANGELOG.md"
end
