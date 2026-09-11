# frozen_string_literal: true

module Overturo
  module ApiOperations
    module Create
      def create(params = {})
        response = http_client.post(resource_path, body: params)
        unwrap(response)
      end
    end
  end
end
