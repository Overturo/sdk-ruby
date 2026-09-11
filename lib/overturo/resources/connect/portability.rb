# frozen_string_literal: true

module Overturo
  module Resources
    module Connect
      # 126-SX-5 — data portability (spec 125-CB-4, Art. 20). List the supported
      # export formats and confirm a cross-border export/import. The self-service
      # *access* DSAR is a web-only export and is not part of the API surface.
      #
      # Application-scoped: every call takes the application_id as its first
      # argument and resolves under /applications/:application_id/portability.
      class Portability < ApiResource
        RESOURCE_PATH = "/applications"

        # GET /applications/:application_id/portability/formats — the supported
        # portability formats.
        def formats(application_id, params = {})
          OverturoObject.new(http_client.get(portability_path(application_id, "formats"), params: params))
        end

        # POST /applications/:application_id/portability/confirm_export —
        # confirm and forward the export.
        def confirm_export(application_id, params = {})
          OverturoObject.new(http_client.post(portability_path(application_id, "confirm_export"), body: params))
        end

        # POST /applications/:application_id/portability/confirm_import —
        # confirm an import.
        def confirm_import(application_id, params = {})
          OverturoObject.new(http_client.post(portability_path(application_id, "confirm_import"), body: params))
        end

        private

        def portability_path(application_id, action)
          "#{resource_path}/#{application_id}/portability/#{action}"
        end
      end
    end
  end
end
