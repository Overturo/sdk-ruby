# frozen_string_literal: true

module Overturo
  module Resources
    module Delegate
      # Durable authorization records — `GET /api/v1/authorization_receipts/:id`.
      # Requires the
      # `audit:verify` token scope. The 404 contract is parity-preserving by
      # design: unknown, foreign-account, and non-authority ids are
      # indistinguishable — don't try to disambiguate client-side.
      class AuthorizationReceipts < ApiResource
        RESOURCE_PATH = "/authorization_receipts"
        OBJECT_KEY = "authorization_receipt"

        # flavor:
        #   nil / "canonical" — the wrapped document (unwrapped to an
        #     OverturoObject here, like every other resource read)
        #   "signed" — the bare signed envelope, returned as a plain Hash:
        #     it is a portable artifact you hand to a record verifier or
        #     write to disk, not an API object
        #   "dpv" — the JSON-LD document, also a plain Hash (the server
        #     responds with application/ld+json; the body is JSON)
        #
        # Typed refusals (422) surface as Overturo::InvalidRequestError with
        # `error_code` — "unknown_flavor", "not_signable", "dpv_unavailable".
        def retrieve(id, flavor: nil)
          params = flavor ? { flavor: flavor } : {}
          response = http_client.get("#{RESOURCE_PATH}/#{id}", params: params)
          return unwrap(response) if flavor.nil? || flavor.to_s == "canonical"

          response
        end
      end
    end
  end
end
