# frozen_string_literal: true

module Overturo
  module Resources
    module Core
      class Me < ApiResource
        RESOURCE_PATH = "/me"
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
