# frozen_string_literal: true

module Overturo
  module Resources
    module Protect
      class DataLicenses < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List

        RESOURCE_PATH = "/data_licenses"
        OBJECT_KEY = "data_license"
        LIST_KEY = "data_licenses"

        custom_action :terminate, method: :post
      end
    end
  end
end
