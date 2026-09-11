# frozen_string_literal: true

module Overturo
  module Resources
    module Agree
      class Collaborations < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/collaborations"
        OBJECT_KEY = "collaboration"
        LIST_KEY = "collaborations"

        custom_action :invite, method: :post, returns: :raw
        custom_action :sign, method: :post
      end
    end
  end
end
