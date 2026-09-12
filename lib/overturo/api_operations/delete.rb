# frozen_string_literal: true

module Overturo
  module ApiOperations
    module Delete
      def self.included(base) = base.declare_endpoint(:delete, "<resource>/{id}")

      def delete(id)
        response = http_client.delete("#{resource_path}/#{id}")
        unwrap(response)
      end
    end
  end
end
