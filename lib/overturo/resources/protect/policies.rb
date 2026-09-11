# frozen_string_literal: true

module Overturo
  module Resources
    module Protect
      class Policies < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Update
        include ApiOperations::Delete

        RESOURCE_PATH = "/policies"
        OBJECT_KEY = "policy"
        LIST_KEY = "policies"

        custom_action :activate, method: :post
        custom_action :revoke, method: :post
        custom_action :share, method: :post, returns: :raw
      end
    end
  end
end
