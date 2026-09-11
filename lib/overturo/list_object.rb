# frozen_string_literal: true

module Overturo
  class ListObject
    include Enumerable

    attr_reader :data, :pagination

    def initialize(data:, pagination:, http_client: nil, resource_path: nil, list_key: nil, params: {})
      @data = data
      @pagination = pagination
      @http_client = http_client
      @resource_path = resource_path
      @list_key = list_key
      @params = params
    end

    def each(&)
      @data.each(&)
    end

    def more?
      return false unless pagination

      page_value(:page, 1) * page_value(:per_page, 25) < page_value(:total, 0)
    end

    alias has_more? more?

    def auto_paging_each(&block)
      return enum_for(:auto_paging_each) unless block_given?

      @data.each(&block)
      return unless @http_client && @resource_path && @list_key

      current_params = @params.dup
      current_page = page_value(:page, 1)

      while pages_remaining?(current_page)
        current_page += 1
        current_params[:page] = current_page
        response = @http_client.get(@resource_path, params: current_params)
        items = response[@list_key] || []
        items.each do |item|
          block.call(item.is_a?(OverturoObject) ? item : OverturoObject.new(item))
        end
        @pagination = response["pagination"] || {}
      end
    end

    def empty?
      @data.empty?
    end

    def size
      @data.size
    end

    alias length size

    private

    def page_value(key, default)
      return default unless pagination

      pagination[key.to_s] || pagination[key.to_sym] || default
    end

    def pages_remaining?(current_page)
      current_page * page_value(:per_page, 25) < page_value(:total, 0)
    end
  end
end
