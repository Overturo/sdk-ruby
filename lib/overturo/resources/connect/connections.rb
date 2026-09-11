# frozen_string_literal: true

module Overturo
  module Resources
    module Connect
      class Connections < ApiResource
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Delete

        RESOURCE_PATH = "/connections"
        OBJECT_KEY = "connection"
        LIST_KEY = "connections"

        custom_action :suspend, method: :post
        custom_action :unsuspend, method: :post
      end
    end
  end
end
