# frozen_string_literal: true

module Overturo
  class ApiResource
    attr_reader :http_client

    def initialize(http_client)
      @http_client = http_client
    end

    def resource_path
      self.class::RESOURCE_PATH
    end

    def object_key
      self.class::OBJECT_KEY
    end

    def list_key
      self.class::LIST_KEY
    end

    def unwrap(response, key = object_key)
      data = response.is_a?(Hash) && response.key?(key) ? response[key] : response
      OverturoObject.new(data)
    end

    def unwrap_list(response, path: resource_path, key: list_key, params: {})
      items = response.is_a?(Hash) && response.key?(key) ? response[key] : []
      pagination = response.is_a?(Hash) ? (response["pagination"] || {}) : {}
      wrapped = items.map { |item| OverturoObject.new(item) }

      ListObject.new(
        data: wrapped,
        pagination: pagination,
        http_client: http_client,
        resource_path: path,
        list_key: key,
        params: params
      )
    end

    class << self
      def custom_action(name, method: :post, path: nil, returns: :object)
        action_path = path || name.to_s

        case returns
        when :object
          define_method(name) do |id, params = {}|
            response = if method == :post
                         http_client.post("#{resource_path}/#{id}/#{action_path}", body: params)
                       else
                         http_client.get("#{resource_path}/#{id}/#{action_path}", params: params)
                       end
            unwrap(response)
          end
        when :raw
          define_method(name) do |id, params = {}|
            response = if method == :post
                         http_client.post("#{resource_path}/#{id}/#{action_path}", body: params)
                       else
                         http_client.get("#{resource_path}/#{id}/#{action_path}", params: params)
                       end
            OverturoObject.new(response)
          end
        when :list
          define_method(name) do |id, params = {}|
            lk = path || name.to_s
            response = http_client.get("#{resource_path}/#{id}/#{lk}", params: params)
            unwrap_list(response, path: "#{resource_path}/#{id}/#{lk}", key: lk, params: params)
          end
        end
      end

      def collection_action(name, method: :post, path: nil)
        action_path = path || name.to_s
        define_method(name) do |params = {}|
          response = if method == :post
                       http_client.post("#{resource_path}/#{action_path}", body: params)
                     else
                       http_client.get("#{resource_path}/#{action_path}", params: params)
                     end
          unwrap(response)
        end
      end
    end
  end
end
