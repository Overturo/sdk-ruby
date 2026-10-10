# frozen_string_literal: true

module Overturo
  module Resources
    module Connect
      # Meetings are nested under applications:
      # /api/v1/applications/:application_id/meeting_consents[/:id][/participants]
      #
      # A meeting is the unit of record: it has a window (scheduled_at / ends_at),
      # a platform identity, a cancellation, and participant rows that carry
      # each person's decision per purpose.
      class MeetingConsents < ApiResource
        include ApiOperations::NestedResource

        RESOURCE_PATH = "/applications"
        declare_endpoint :get, "<resource>/{application_id}/meeting_consents/{id}/participants"
        OBJECT_KEY = "meeting_consent"
        LIST_KEY = "meeting_consents"

        nested_resource :meeting_consent,
                        path: "meeting_consents",
                        object_key: "meeting_consent",
                        list_key: "meeting_consents",
                        operations: %i[create retrieve list update delete]

        # Public API aliases — take (application_id, ...) as first arg.
        def create(application_id, params = {})
          create_meeting_consent(application_id, params)
        end

        def retrieve(application_id, id)
          retrieve_meeting_consent(application_id, id)
        end

        def list(application_id, params = {})
          list_meeting_consents(application_id, params)
        end

        # Rename or reschedule (title, scheduled_at, duration_minutes, platform,
        # external_meeting_id).
        def update(application_id, id, params = {})
          update_meeting_consent(application_id, id, params)
        end

        # Cancels the meeting (participants are told; the record stays).
        def cancel(application_id, id)
          delete_meeting_consent(application_id, id)
        end
        alias delete cancel

        # The meeting's participants with their decisions per purpose.
        def participants(application_id, id, params = {})
          path = "#{RESOURCE_PATH}/#{application_id}/meeting_consents/#{id}/participants"
          response = http_client.get(path, params: params)
          unwrap_list(response, path: path, key: "participants", params: params)
        end
      end
    end
  end
end
