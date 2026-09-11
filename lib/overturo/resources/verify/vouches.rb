# frozen_string_literal: true

module Overturo
  module Resources
    module Verify
      # `/api/v1/vouches` supports index/create/show/destroy plus the
      # `/received` collection action. There is **no** PATCH endpoint —
      # vouches are immutable once issued.
      class Vouches < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Delete

        RESOURCE_PATH = "/vouches"
        OBJECT_KEY = "vouch"
        LIST_KEY = "vouches"

        def received(params = {})
          received_path = "#{resource_path}/received"
          response = http_client.get(received_path, params: params)
          unwrap_list(response, path: received_path, key: list_key, params: params)
        end
      end
    end
  end
end
