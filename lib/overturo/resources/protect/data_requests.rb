# frozen_string_literal: true

module Overturo
  module Resources
    module Protect
      class DataRequests < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/data_requests"
        OBJECT_KEY = "data_request"
        LIST_KEY = "data_requests"
      end
    end
  end
end
