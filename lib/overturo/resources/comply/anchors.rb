# frozen_string_literal: true

module Overturo
  module Resources
    module Comply
      class Anchors < ApiResource
        include ApiOperations::Retrieve

        RESOURCE_PATH = "/anchors"
        # 193 D12 — endpoints built by explicit http_client calls below.
        declare_endpoint :get, "<resource>/{id}/receipts"
        OBJECT_KEY = "anchor"
        LIST_KEY = "anchors"

        custom_action :export, method: :get, returns: :raw

        def receipts(id, params = {})
          receipts_path = "#{resource_path}/#{id}/receipts"
          response = http_client.get(receipts_path, params: params)
          unwrap_list(response, path: receipts_path, key: "receipts", params: params)
        end
      end
    end
  end
end
