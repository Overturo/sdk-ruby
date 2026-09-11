# frozen_string_literal: true

module Overturo
  module Resources
    module Agree
      # 106-TS-2 Phase A — renamed from Decisions to QuorumRequests so the
      # /api/v1/decisions URL family is free for the TrustSurface decisions
      # API. The underlying surface is the M-of-N quorum authorization on
      # Agreement actions ("collective guardianship" per the Agree surface).
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
