# frozen_string_literal: true

module Overturo
  module ApiOperations
    module Delete
      def delete(id)
        response = http_client.delete("#{resource_path}/#{id}")
        unwrap(response)
      end
    end
  end
end
