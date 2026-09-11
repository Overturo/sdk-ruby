# frozen_string_literal: true

module Overturo
  module Resources
    module Consent
      class Entitlements < ApiResource
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/entitlements"
        OBJECT_KEY = "entitlement"
        LIST_KEY = "entitlements"

        custom_action :verify, method: :post, returns: :raw
      end
    end
  end
end
