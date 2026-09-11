# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "securerandom"

module Overturo
  class HttpClient
    RETRY_SLEEP_BASE = 0.5

    attr_reader :last_request_id

    def initialize(config)
      @config = config
    end

    def get(path, params: {}, headers: {})
      request(:get, path, params: params, extra_request_headers: headers)
    end

    def post(path, body: {}, idempotency_key: nil)
      request(:post, path, body: body, idempotency_key: idempotency_key)
    end

    def patch(path, body: {}, idempotency_key: nil)
      request(:patch, path, body: body, idempotency_key: idempotency_key)
    end

    def delete(path)
      request(:delete, path)
    end

    private

    def request(method, path, params: {}, body: nil, idempotency_key: nil, extra_request_headers: {})
      uri = build_uri(path, params)
      request_id = generate_request_id
      retries = 0

      begin
        response = execute_request(method, uri, body, request_id: request_id, idempotency_key: idempotency_key,
                                                      extra_request_headers: extra_request_headers)
        handle_response(response)
      rescue RateLimitError, ApiError, ConnectionError, TimeoutError => e
        if retries < @config.max_retries && retryable?(e)
          retries += 1
          sleep_time = RETRY_SLEEP_BASE * (2**(retries - 1))
          log(:warn, "Retrying request #{request_id} (attempt #{retries}/#{@config.max_retries}) after #{sleep_time}s")
          sleep(sleep_time)
          retry
        end
        raise
      end
    end

    def execute_request(method, uri, body, request_id: nil, idempotency_key: nil, extra_request_headers: {})
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @config.open_timeout
      http.read_timeout = @config.read_timeout
      http.write_timeout = @config.write_timeout

      req = build_request(method, uri, body, request_id: request_id, idempotency_key: idempotency_key,
                                             extra_request_headers: extra_request_headers)
      log(:debug, "[#{request_id}] #{method.upcase} #{uri.path}")
      http.request(req)
    rescue ::Timeout::Error, Errno::ETIMEDOUT => e
      raise Overturo::TimeoutError, "Request timed out: #{e.message}"
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH,
           Errno::ENETUNREACH, SocketError, EOFError => e
      raise Overturo::ConnectionError, "Connection failed: #{e.message}"
    end

    def build_request(method, uri, body, request_id: nil, idempotency_key: nil, extra_request_headers: {})
      klass = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        patch: Net::HTTP::Patch,
        delete: Net::HTTP::Delete
      }.fetch(method)

      extra_headers = {}
      extra_headers["X-Request-ID"] = request_id if request_id
      extra_headers["Idempotency-Key"] = idempotency_key if idempotency_key
      # 189 — caller-supplied per-request headers (e.g. the discovery resource's
      # X-Publishable-Key). Merged last so an explicit header wins.
      extra_headers.merge!(extra_request_headers) if extra_request_headers && !extra_request_headers.empty?

      req = klass.new(uri.request_uri, headers.merge(extra_headers))
      req.body = JSON.generate(body) if body && !body.empty?
      req
    end

    def build_uri(path, params)
      # chomp a trailing slash so a base_url like "https://x.com/" doesn't produce
      # "https://x.com//api/..." (some gateways 404 the double slash).
      url = "#{@config.base_url.to_s.chomp("/")}/api/#{@config.api_version}#{path}"
      uri = URI.parse(url)
      uri.query = URI.encode_www_form(params) if params && !params.empty?
      uri
    end

    def headers
      {
        "Authorization" => "Bearer #{@config.api_key}",
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "overturo-ruby/#{Overturo::VERSION}"
      }
    end

    def handle_response(response)
      @last_response_request_id = response["X-Request-ID"]
      status = response.code.to_i
      body = response.body
      json = parse_json(body)

      return json || {} if status >= 200 && status < 300

      message = json.is_a?(Hash) ? (json["error"] || body) : body
      error_class = ERROR_MAP[status] || (status >= 500 ? ApiError : Error)

      raise error_class.new(
        message.to_s,
        http_status: status,
        http_body: body,
        json_body: json
      )
    end

    def parse_json(body)
      return nil if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end

    def retryable?(error)
      error.is_a?(RateLimitError) || error.is_a?(ApiError) ||
        error.is_a?(ConnectionError) || error.is_a?(TimeoutError)
    end

    def generate_request_id
      @last_request_id = "req_#{SecureRandom.hex(12)}"
    end

    def log(level, message)
      return unless @config.logger

      @config.logger.send(level, "[Overturo] #{message}")
    end
  end
end
