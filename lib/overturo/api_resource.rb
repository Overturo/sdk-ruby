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

    # Member-action transport: the verb the API declares for the action.
    def member_request(method, path, params)
      case method
      when :post then http_client.post(path, body: params)
      when :patch then http_client.patch(path, body: params)
      else http_client.get(path, params: params)
      end
    end

    def unwrap(response, key = object_key)
      data = response.is_a?(Hash) && response.key?(key) ? response[key] : response
      OverturoObject.new(data)
    end

    def unwrap_list(response, path: resource_path, key: list_key, params: {})
      items = if response.is_a?(Array) then response # a bare collection (the accounts API renders one)
              elsif response.is_a?(Hash) && response.key?(key) then response[key]
              else
                []
              end
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
      # 193 D12 — every endpoint this class can construct, as [METHOD, template].
      # Macros record templates with a <resource> token because `include
      # ApiOperations::*` precedes RESOURCE_PATH in most classes; the token is
      # expanded lazily here. Explicit http_client calls declare themselves.
      def declare_endpoint(method, template)
        (@declared_templates ||= []) << [method.to_s.upcase, template]
      end

      def declared_endpoints
        (@declared_templates || []).map { |m, t| [m, t.sub("<resource>", self::RESOURCE_PATH)] }.uniq
      end

      def custom_action(name, method: :post, path: nil, returns: :object)
        action_path = path || name.to_s
        declare_endpoint(method, "<resource>/{id}/#{action_path}")

        case returns
        when :object
          define_method(name) do |id, params = {}|
            unwrap(member_request(method, "#{resource_path}/#{id}/#{action_path}", params))
          end
        when :raw
          define_method(name) do |id, params = {}|
            OverturoObject.new(member_request(method, "#{resource_path}/#{id}/#{action_path}", params))
          end
        when :list
          raise ArgumentError, "custom_action #{name}: returns: :list is GET-only (declared #{method})" unless method == :get

          define_method(name) do |id, params = {}|
            lk = path || name.to_s
            response = http_client.get("#{resource_path}/#{id}/#{lk}", params: params)
            unwrap_list(response, path: "#{resource_path}/#{id}/#{lk}", key: lk, params: params)
          end
        end
      end

      def collection_action(name, method: :post, path: nil)
        action_path = path || name.to_s
        declare_endpoint(method, "<resource>/#{action_path}")
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
