# frozen_string_literal: true

module Overturo
  module Resources
    module Comply
      class EvidencePackages < ApiResource
        include ApiOperations::Retrieve

        RESOURCE_PATH = "/evidence_packages"
        OBJECT_KEY = "evidence_package"
        LIST_KEY = "evidence_packages"
      end
    end
  end
end
