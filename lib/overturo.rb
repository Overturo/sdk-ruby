# frozen_string_literal: true

require_relative "overturo/version"
require_relative "overturo/errors"
require_relative "overturo/configuration"
require_relative "overturo/overturo_object"
require_relative "overturo/list_object"
require_relative "overturo/http_client"
require_relative "overturo/api_resource"
require_relative "overturo/api_operations/create"
require_relative "overturo/api_operations/retrieve"
require_relative "overturo/api_operations/list"
require_relative "overturo/api_operations/update"
require_relative "overturo/api_operations/delete"
require_relative "overturo/api_operations/nested_resource"
require_relative "overturo/client"

# Resources — Core
require_relative "overturo/resources/core/me"
require_relative "overturo/resources/core/accounts"

# Resources — Connect
require_relative "overturo/resources/connect/applications"
require_relative "overturo/resources/connect/webhooks"
require_relative "overturo/resources/connect/connections"
require_relative "overturo/resources/connect/flows"
require_relative "overturo/resources/connect/portability"

# Resources — Consent
require_relative "overturo/resources/consent/consent_sessions"
require_relative "overturo/resources/consent/decisions"
require_relative "overturo/resources/consent/entitlements"
require_relative "overturo/resources/consent/trust_levels"

# Resources — Verify
require_relative "overturo/resources/verify/credentials"
require_relative "overturo/resources/verify/verification_sessions"
require_relative "overturo/resources/verify/presentations"
require_relative "overturo/resources/verify/trust_scores"
require_relative "overturo/resources/verify/vouches"

# Resources — Protect
require_relative "overturo/resources/protect/policies"
require_relative "overturo/resources/protect/data_requests"
require_relative "overturo/resources/protect/transfers"
require_relative "overturo/resources/protect/data_licenses"

# Resources — Agree
require_relative "overturo/resources/agree/agreements"
require_relative "overturo/resources/agree/quorum_requests"
require_relative "overturo/resources/agree/collaborations"

# Resources — Delegate
require_relative "overturo/resources/delegate/delegations"
require_relative "overturo/resources/delegate/agent_identities"
require_relative "overturo/resources/delegate/security_event_streams"
require_relative "overturo/resources/delegate/authorization_receipts"
require_relative "overturo/resources/delegate/disclosure_receipts"

# Resources — Comply
require_relative "overturo/resources/comply/anchors"
require_relative "overturo/resources/comply/evidence_packages"
require_relative "overturo/resources/comply/clean_rooms"
require_relative "overturo/resources/comply/transfer_register"
require_relative "overturo/resources/comply/residency_posture"

module Overturo
  class << self
    def configure
      yield(configuration) if block_given?
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def api_key=(key)
      configuration.api_key = key
    end
  end
end
