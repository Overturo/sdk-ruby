# frozen_string_literal: true

module Overturo
  module Resources
    module Core
      class Me < ApiResource
        RESOURCE_PATH = "/me"
        # 193 D12 — endpoints built by explicit http_client calls below.
        declare_endpoint :get, "<resource>"
        OBJECT_KEY = "user"
        LIST_KEY = nil

        def retrieve
          response = http_client.get(resource_path)
          unwrap(response)
        end
      end
    end
  end
end
