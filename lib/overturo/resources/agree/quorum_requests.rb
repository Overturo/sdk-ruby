# frozen_string_literal: true

module Overturo
  module Resources
    module Agree
      # M-of-N quorum authorization on Agreement actions ("collective
      # guardianship" per the Agree surface). Lives at /api/v1/quorum_requests;
      # /api/v1/decisions is the separate decisions API.
      class QuorumRequests < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/quorum_requests"
        OBJECT_KEY = "quorum_request"
        LIST_KEY = "quorum_requests"

        custom_action :vote, method: :post
      end
    end
  end
end
