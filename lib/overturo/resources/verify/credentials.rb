# frozen_string_literal: true

module Overturo
  module Resources
    module Verify
      # `/api/v1/credentials` supports index/create/show/destroy plus the
      # `/wallet_pass` member action. There is **no** PATCH endpoint —
      # credentials are immutable once issued. Earlier versions of this SDK
      # included Update; that path returned 404.
      class Credentials < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Delete

        RESOURCE_PATH = "/credentials"
        OBJECT_KEY = "credential"
        LIST_KEY = "credentials"

        custom_action :wallet_pass, method: :get, returns: :raw
      end
    end
  end
end
