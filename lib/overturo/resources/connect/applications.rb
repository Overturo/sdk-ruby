# frozen_string_literal: true

module Overturo
  module Resources
    module Connect
      # Only the `publish` and `unpublish` member actions exist at the top
      # level. Creating an application happens via the dashboard; per-application
      # configuration uses the nested `applications/:id/...` resources — see
      # Connect::Webhooks and Connect::Flows.
      class Applications < ApiResource
        RESOURCE_PATH = "/applications"
        OBJECT_KEY = "application"
        LIST_KEY = "applications"

        custom_action :publish, method: :post
        custom_action :unpublish, method: :post
      end
    end
  end
end
