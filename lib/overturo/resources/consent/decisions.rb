# frozen_string_literal: true

require "cgi"

module Overturo
  module Resources
    module Consent
      # 189 — pre-flight disclosure discovery. Returns what the decision screen
      # would present for a consent flow (purposes, fields, steps, the action
      # label, expiry, application branding) BEFORE any session exists, in public
      # vocabulary and the requested locale.
      #
      # Publishable-key authenticated: the publishable key (pk_live_… / pk_test_…)
      # is an embed-safe, per-application credential passed EXPLICITLY per call
      # rather than via client config — this endpoint ignores the client's bearer
      # token, so the publishable key is the only credential that matters. An
      # unknown / foreign / non-consent flow answers a uniform 404
      # (Overturo::NotFoundError).
      class Decisions < ApiResource
        RESOURCE_PATH = "/decisions"
        # 193 D12 — endpoints built by explicit http_client calls below.
        declare_endpoint :get, "<resource>/flows/{flow_id}/disclosures"

        def discover(flow_id, publishable_key:, locale: nil)
          raise ArgumentError, "flow_id is required" if flow_id.nil? || flow_id.to_s.empty?
          raise ArgumentError, "publishable_key is required" if publishable_key.nil? || publishable_key.to_s.empty?

          path = "#{resource_path}/flows/#{CGI.escape(flow_id.to_s)}/disclosures"
          # Only send ?locale= for a non-blank locale (in Ruby "" is truthy, so a
          # bare truthiness check would emit ?locale= — the JS/py clients omit it).
          params = locale.to_s.empty? ? {} : { locale: locale }
          response = http_client.get(path, params: params, headers: { "X-Publishable-Key" => publishable_key })

          # The server wraps the inventory as {"flow" => {...}}; return the
          # inventory itself, matching the JS/py/node
          # clients' `envelope.flow`. An envelope-less 200 (a proxy/gateway
          # misconfig — the server is fail-closed) is a typed error, never a
          # silent pass-through of the whole body dressed up as the inventory.
          raise Overturo::ApiError, "Malformed discovery response: missing 'flow' in body" unless response.is_a?(Hash) && response.key?("flow")

          OverturoObject.new(response.fetch("flow"))
        end
      end
    end
  end
end
