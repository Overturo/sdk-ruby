# frozen_string_literal: true

module Overturo
  module ApiOperations
    module NestedResource
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # `list_key` names the JSON key the API wraps the collection in; the
        # generated method is always `list_<plural name>` (`list_method` overrides).
        def nested_resource(name, path:, object_key: nil, list_key: nil, list_method: nil, operations: [])
          { create: [:post, "<resource>/{parent_id}/#{path}"], retrieve: [:get, "<resource>/{parent_id}/#{path}/{id}"],
            list: [:get, "<resource>/{parent_id}/#{path}"], update: [:patch, "<resource>/{parent_id}/#{path}/{id}"],
            delete: [:delete, "<resource>/{parent_id}/#{path}/{id}"] }.each { |op, (m, t)| declare_endpoint(m, t) if operations.include?(op) }
          operations.each do |op|
            case op
            when :create
              define_method(:"create_#{name}") do |parent_id, params = {}|
                response = http_client.post("#{resource_path}/#{parent_id}/#{path}", body: params)
                unwrap(response, object_key || name.to_s)
              end
            when :retrieve
              define_method(:"retrieve_#{name}") do |parent_id, id|
                response = http_client.get("#{resource_path}/#{parent_id}/#{path}/#{id}")
                unwrap(response, object_key || name.to_s)
              end
            when :list
              define_method(:"list_#{list_method || "#{name}s"}") do |parent_id, params = {}|
                lk = list_key || "#{name}s"
                nested_path = "#{resource_path}/#{parent_id}/#{path}"
                response = http_client.get(nested_path, params: params)
                unwrap_list(response, path: nested_path, key: lk, params: params)
              end
            when :update
              define_method(:"update_#{name}") do |parent_id, id, params = {}|
                response = http_client.patch("#{resource_path}/#{parent_id}/#{path}/#{id}", body: params)
                unwrap(response, object_key || name.to_s)
              end
            when :delete
              define_method(:"delete_#{name}") do |parent_id, id|
                response = http_client.delete("#{resource_path}/#{parent_id}/#{path}/#{id}")
                unwrap(response, object_key || name.to_s)
              end
            end
          end
        end
      end
    end
  end
end
