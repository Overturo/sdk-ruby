# frozen_string_literal: true

module Overturo
  module Resources
    module Core
      # The accounts API is list-only. Account creation happens through the
      # dashboard signup flow, not the API, and per-account configuration is
      # managed server-side.
      class Accounts < ApiResource
        include ApiOperations::List

        RESOURCE_PATH = "/accounts"
        OBJECT_KEY = "account"
        LIST_KEY = "accounts"
      end
    end
  end
end
