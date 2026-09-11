# frozen_string_literal: true

module Overturo
  module ApiOperations
    module Retrieve
      def retrieve(id)
        response = http_client.get("#{resource_path}/#{id}")
        unwrap(response)
      end
    end
  end
end
