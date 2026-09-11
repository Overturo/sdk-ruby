# frozen_string_literal: true

module Overturo
  module Resources
    module Connect
      # The top-level applications route is `resources :applications, only: []` —
      # only the `publish` and `unpublish` member actions exist at this level.
      # Per-application CRUD lives elsewhere (creating an application happens
      # via the dashboard; per-application configuration uses the nested
      # `applications/:id/...` routes — see Connect::Webhooks, Connect::Flows).
      #
      # Earlier versions of this SDK included Create/Retrieve/List/Update/Delete
      # against `/api/v1/applications`; all five of those calls returned 404.
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
