# frozen_string_literal: true

module Overturo
  # The machine-readable manifest of every endpoint this gem can call, derived
  # from the resource classes' declared endpoints. `endpoints.json` at the gem
  # root is the committed copy (rake endpoints:write); spec/overturo/endpoints_spec.rb
  # keeps the two equal.
  module Endpoints
    def self.resource_classes
      Overturo::Resources.constants.sort.flat_map do |surface|
        mod = Overturo::Resources.const_get(surface)
        mod.constants.sort.map { |c| mod.const_get(c) }.select { |k| k.is_a?(Class) && k < Overturo::ApiResource }
      end
    end

    def self.manifest
      entries = resource_classes.flat_map do |klass|
        klass.declared_endpoints.map { |m, t| { "method" => m, "path" => "/api/v1#{t}", "resource" => klass.name } }
      end
      entries.uniq.sort_by { |e| [e["path"], e["method"]] }
    end

    def self.document
      { "sdk" => "overturo-ruby", "endpoints" => manifest }
    end
  end
end
