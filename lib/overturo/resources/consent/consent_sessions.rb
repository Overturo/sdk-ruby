# frozen_string_literal: true

module Overturo
  module Resources
    module Consent
      class ConsentSessions < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve

        RESOURCE_PATH = "/consent_sessions"
        # 193 D12 — endpoints built by explicit http_client calls below.
        declare_endpoint :post, "<resource>/{id}/exchange"
        OBJECT_KEY = "consent_session"
        LIST_KEY = "consent_sessions"

        custom_action :authorize, method: :post
        custom_action :verify, method: :get

        # Exchange a consent token for claims, attestations, credentials, and tokens.
        # Handles HTTP 202 (fulfillment pending) transparently by retrying with
        # the Retry-After interval until the server returns the full result.
        def exchange(id, params = {})
          max_retries = 5
          path = "#{resource_path}/#{id}/exchange"

          (max_retries + 1).times do |attempt|
            response = http_client.post(path, body: params)

            # HttpClient returns parsed JSON for all 2xx responses.
            # A 202 returns {status: "pending", ...} — detect and retry.
            if response.is_a?(Hash) && response["status"] == "pending"
              if attempt == max_retries
                raise Overturo::ApiError.new(
                  "Exchange timeout: fulfillment still pending",
                  http_status: 202
                )
              end

              sleep(1)
              next
            end

            return OverturoObject.new(response)
          end
        end
      end
    end
  end
end
