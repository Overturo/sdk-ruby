# frozen_string_literal: true

module Overturo
  class Configuration
    attr_accessor :api_key, :base_url, :api_version,
                  :open_timeout, :read_timeout, :write_timeout,
                  :max_retries, :logger

    def initialize
      @api_key = nil
      @base_url = "https://overturo.com"
      @api_version = "v1"
      @open_timeout = 30
      @read_timeout = 80
      @write_timeout = 30
      @max_retries = 2
      @logger = nil
    end

    def validate!
      raise AuthenticationError, "No API key provided. Set your API key using Overturo::Client.new(api_key: \"sk_live_...\")" unless api_key && !api_key.empty?
    end
  end
end
