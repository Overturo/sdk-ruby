# frozen_string_literal: true

module Overturo
  module Resources
    module Delegate
      class AgentIdentities < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Update
        include ApiOperations::Delete

        RESOURCE_PATH = "/agent_identities"
        OBJECT_KEY = "agent_identity"
        LIST_KEY = "agent_identities"

        custom_action :delegate, method: :post
        custom_action :suspend, method: :post
        custom_action :reactivate, method: :post
      end
    end
  end
end
