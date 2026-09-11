# frozen_string_literal: true

module Overturo
  class OverturoObject
    def initialize(data = {})
      @data = {}
      data.each { |k, v| @data[k.to_s] = wrap_value(v) }
    end

    def [](key)
      @data[key.to_s]
    end

    def []=(key, value)
      @data[key.to_s] = wrap_value(value)
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.key?(method_name.to_s) || super
    end

    def method_missing(method_name, *args)
      key = method_name.to_s
      if @data.key?(key)
        @data[key]
      else
        super
      end
    end

    def to_h
      @data.transform_values { |v| unwrap_value(v) }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    def to_s
      "#<#{self.class} #{@data.map { |k, v| "#{k}=#{v.inspect}" }.join(" ")}>"
    end

    def inspect
      to_s
    end

    def key?(key)
      @data.key?(key.to_s)
    end

    def keys
      @data.keys
    end

    def values
      @data.values
    end

    def each(&)
      @data.each(&)
    end

    private

    def wrap_value(value)
      case value
      when Hash
        OverturoObject.new(value)
      when Array
        value.map { |v| wrap_value(v) }
      else
        value
      end
    end

    def unwrap_value(value)
      case value
      when OverturoObject
        value.to_h
      when Array
        value.map { |v| unwrap_value(v) }
      else
        value
      end
    end
  end
end
