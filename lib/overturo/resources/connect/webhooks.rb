# frozen_string_literal: true

module Overturo
  module Resources
    module Connect
      class Webhooks < ApiResource
        include ApiOperations::NestedResource

        RESOURCE_PATH = "/applications"
        OBJECT_KEY = "webhook_subscription"
        LIST_KEY = "webhook_subscriptions"

        nested_resource :webhook,
                        path: "webhooks",
                        object_key: "webhook_subscription",
                        list_key: "webhook_subscriptions",
                        operations: %i[create retrieve list update delete]

        # Public API aliases: take (application_id, ...) as first arg
        def create(application_id, params = {})
          create_webhook(application_id, params)
        end

        def retrieve(application_id, id)
          retrieve_webhook(application_id, id)
        end

        def list(application_id, params = {})
          list_webhooks(application_id, params)
        end

        def update(application_id, id, params = {})
          update_webhook(application_id, id, params)
        end

        def delete(application_id, id)
          delete_webhook(application_id, id)
        end
      end
    end
  end
end
