# frozen_string_literal: true

module Overturo
  module Resources
    module Connect
      # Flows are nested under applications:
      # /api/v1/applications/:application_id/flows[/:id][/<action>]
      class Flows < ApiResource
        include ApiOperations::NestedResource

        RESOURCE_PATH = "/applications"
        OBJECT_KEY = "flow"
        LIST_KEY = "flows"

        nested_resource :flow,
                        path: "flows",
                        object_key: "flow",
                        list_key: "flows",
                        operations: %i[create retrieve list update delete]

        # Public API aliases — take (application_id, ...) as first arg.
        def create(application_id, params = {})
          create_flow(application_id, params)
        end

        def retrieve(application_id, id)
          retrieve_flow(application_id, id)
        end

        def list(application_id, params = {})
          list_flows(application_id, params)
        end

        def update(application_id, id, params = {})
          update_flow(application_id, id, params)
        end

        def delete(application_id, id)
          delete_flow(application_id, id)
        end

        # Member actions on the nested resource. NestedResource doesn't have a
        # `nested_custom_action` helper yet, so these are written explicitly.
        def activate(application_id, id, params = {})
          member_action(application_id, id, "activate", params)
        end

        def deprecate(application_id, id, params = {})
          member_action(application_id, id, "deprecate", params)
        end

        def archive(application_id, id, params = {})
          member_action(application_id, id, "archive", params)
        end

        def resolve_preview(application_id, id, params = {})
          member_action(application_id, id, "resolve_preview", params)
        end

        private

        def member_action(application_id, id, action, params)
          response = http_client.post(
            "#{RESOURCE_PATH}/#{application_id}/flows/#{id}/#{action}",
            body: params
          )
          unwrap(response)
        end
      end
    end
  end
end
