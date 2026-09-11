# frozen_string_literal: true

module Overturo
  module Resources
    module Verify
      class TrustScores < ApiResource
        include ApiOperations::List

        RESOURCE_PATH = "/trust_scores"
        OBJECT_KEY = "trust_score"
        LIST_KEY = "trust_scores"

        collection_action :query, method: :post
      end
    end
  end
end
