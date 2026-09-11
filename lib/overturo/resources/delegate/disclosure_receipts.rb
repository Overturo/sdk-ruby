# frozen_string_literal: true

module Overturo
  module Resources
    module Delegate
      # Operator-declared disclosure receipts — `POST /api/v1/disclosure_receipts`.
      # Requires the `disclosures:write`
      # token scope. Mint-only by design: the operator disclosure log page is the
      # read side (programmatic reads are a registered deferred capability).
      #
      # Payload: flow_id, agent_id, disclosed_at (ISO 8601), optional locale.
      # The 201 unwraps to {record_id:, record:}. Typed refusals (422) surface
      # as Overturo::InvalidRequestError with `error_code` — this endpoint's
      # shape is {"error" => <human message>, "code" => <machine code>}
      # ("agent_not_disclosed", "invalid_disclosed_at", "purposes_missing").
      class DisclosureReceipts < ApiResource
        include ApiOperations::Create

        RESOURCE_PATH = "/disclosure_receipts"
        OBJECT_KEY = "disclosure_receipt"
      end
    end
  end
end
