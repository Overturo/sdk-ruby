# frozen_string_literal: true

module Overturo
  module Resources
    module Comply
      # Read the cross-border transfer register and export
      # its signed, verifiable evidence package. Each entry carries the lawful
      # basis it relied on, the adequacy verdict, and the country pair. Read and
      # export only — the SDK never creates a transfer.
      class TransferRegister < ApiResource
        include ApiOperations::List

        RESOURCE_PATH = "/transfer_register"
        OBJECT_KEY = "transfer"
        LIST_KEY = "transfers"

        # POST /transfer_register/evidence_package — the signed, anchored,
        # independently-verifiable evidence package of the register.
        def evidence_package(params = {})
          response = http_client.post("#{resource_path}/evidence_package", body: params)
          OverturoObject.new(response)
        end
      end
    end
  end
end
