# frozen_string_literal: true

module Overturo
  module ApiOperations
    module Update
      def update(id, params = {})
        response = http_client.patch("#{resource_path}/#{id}", body: params)
        unwrap(response)
      end
    end
  end
end
