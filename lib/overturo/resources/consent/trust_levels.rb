# frozen_string_literal: true

module Overturo
  module Resources
    module Consent
      class TrustLevels < ApiResource
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/trust_levels"
        OBJECT_KEY = "trust_level"
        LIST_KEY = "trust_levels"

        custom_action :trigger, method: :post
      end
    end
  end
end
