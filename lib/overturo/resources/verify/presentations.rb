# frozen_string_literal: true

module Overturo
  module Resources
    module Verify
      class Presentations < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve

        RESOURCE_PATH = "/presentations"
        OBJECT_KEY = "presentation"
        LIST_KEY = "presentations"

        custom_action :present, method: :patch, returns: :raw
      end
    end
  end
end
