# frozen_string_literal: true

module Overturo
  module Resources
    module Comply
      class CleanRooms < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve
        include ApiOperations::List
        include ApiOperations::Delete

        RESOURCE_PATH = "/clean_rooms"
        OBJECT_KEY = "clean_room"
        LIST_KEY = "clean_rooms"

        custom_action :approve, method: :post

        # 126-SX-5 — compute-to-data (spec 125-CB-3). Run a query inside the
        # clean room and read its result. The result carries its privacy
        # parameters (`k_anonymity_met`, `noise_parameters`) and a first-class
        # `suppressed` flag + `suppression_reason`: a full k-anonymity
        # suppression is surfaced honestly, never returned as a silent empty.
        def run_query(id, params = {})
          path = "#{resource_path}/#{id}/queries"
          OverturoObject.new(http_client.post(path, body: params))
        end

        # GET /clean_rooms/:id/queries — list prior compute-to-data queries.
        def queries(id, params = {})
          path = "#{resource_path}/#{id}/queries"
          unwrap_list(http_client.get(path, params: params), path: path, key: "queries", params: params)
        end

        # GET /clean_rooms/:id/queries/:query_id — read a single query result.
        def query(id, query_id, params = {})
          path = "#{resource_path}/#{id}/queries/#{query_id}"
          OverturoObject.new(http_client.get(path, params: params))
        end
      end
    end
  end
end
