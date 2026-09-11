# frozen_string_literal: true

module Overturo
  module ApiOperations
    module List
      def list(params = {})
        response = http_client.get(resource_path, params: params)
        unwrap_list(response, params: params)
      end
    end
  end
end
