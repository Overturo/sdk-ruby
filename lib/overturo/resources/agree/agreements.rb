# frozen_string_literal: true

module Overturo
  module Resources
    module Agree
      class Agreements < ApiResource
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/agreements"
        OBJECT_KEY = "agreement"
        LIST_KEY = "agreements"

        collection_action :propose, method: :post
        custom_action :counter, method: :post
        custom_action :accept, method: :post
      end
    end
  end
end
