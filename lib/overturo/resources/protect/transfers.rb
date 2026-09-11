# frozen_string_literal: true

module Overturo
  module Resources
    module Protect
      class Transfers < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/transfers"
        OBJECT_KEY = "transfer"
        LIST_KEY = "transfers"

        custom_action :cancel, method: :post
      end
    end
  end
end
