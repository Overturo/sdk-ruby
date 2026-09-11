# frozen_string_literal: true

module Overturo
  module Resources
    module Delegate
      class SecurityEventStreams < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Update
        include ApiOperations::Delete

        RESOURCE_PATH = "/security_event_streams"
        OBJECT_KEY = "security_event_stream"
        LIST_KEY = "security_event_streams"

        custom_action :verify, method: :post, returns: :raw
        custom_action :poll, method: :get, returns: :raw
      end
    end
  end
end
