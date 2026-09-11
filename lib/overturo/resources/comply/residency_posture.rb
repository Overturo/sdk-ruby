# frozen_string_literal: true

module Overturo
  module Resources
    module Comply
      # 126-SX-5 — read your residency posture (spec 117): a per-country map of
      # where your subjects' data is stored, the disclosure ledger, and an
      # assurance status. Export a signed Proof of Residency. Singleton (no id).
      class ResidencyPosture < ApiResource
        RESOURCE_PATH = "/residency_posture"
        OBJECT_KEY = "residency_posture"

        # GET /residency_posture — the per-country posture + assurance status.
        def get(params = {})
          response = http_client.get(resource_path, params: params)
          OverturoObject.new(response)
        end

        # POST /residency_posture/evidence_package — the signed, anchored Proof
        # of Residency, on the same verifiable path as the transfer register.
        def evidence_package(params = {})
          response = http_client.post("#{resource_path}/evidence_package", body: params)
          OverturoObject.new(response)
        end
      end
    end
  end
end
