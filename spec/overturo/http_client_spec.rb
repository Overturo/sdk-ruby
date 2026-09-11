# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::HttpClient do
  let(:config) do
    c = Overturo::Configuration.new
    c.api_key = "sk_test_123"
    c.max_retries = 0
    c
  end
  let(:http_client) { described_class.new(config) }

  describe "#get" do
    it "sends a GET request with auth header" do
      stub = stub_api(:get, "/test", body: { "result" => "ok" })

      result = http_client.get("/test")

      expect(stub).to have_been_requested
      expect(result).to eq({ "result" => "ok" })
    end

    it "includes query params" do
      stub = stub_request(:get, "https://overturo.com/api/v1/test?page=2&per_page=10")
             .to_return(status: 200, body: '{"data": []}', headers: { "Content-Type" => "application/json" })

      http_client.get("/test", params: { page: 2, per_page: 10 })
      expect(stub).to have_been_requested
    end

    it "sends Authorization Bearer header" do
      stub_api(:get, "/test", body: {})

      http_client.get("/test")

      expect(WebMock).to have_requested(:get, "https://overturo.com/api/v1/test")
        .with(headers: { "Authorization" => "Bearer sk_test_123" })
    end

    it "sends User-Agent header" do
      stub_api(:get, "/test", body: {})

      http_client.get("/test")

      expect(WebMock).to have_requested(:get, "https://overturo.com/api/v1/test")
        .with(headers: { "User-Agent" => "overturo-ruby/#{Overturo::VERSION}" })
    end
  end

  describe "#post" do
    it "sends a POST request with JSON body" do
      stub = stub_request(:post, "https://overturo.com/api/v1/test")
             .with(body: '{"name":"test"}')
             .to_return(status: 201, body: '{"id": "123"}', headers: { "Content-Type" => "application/json" })

      result = http_client.post("/test", body: { name: "test" })
      expect(stub).to have_been_requested
      expect(result).to eq({ "id" => "123" })
    end
  end

  describe "#patch" do
    it "sends a PATCH request" do
      stub = stub_request(:patch, "https://overturo.com/api/v1/test/123")
             .with(body: '{"name":"updated"}')
             .to_return(status: 200, body: '{"id": "123", "name": "updated"}', headers: { "Content-Type" => "application/json" })

      result = http_client.patch("/test/123", body: { name: "updated" })
      expect(stub).to have_been_requested
      expect(result["name"]).to eq("updated")
    end
  end

  describe "#delete" do
    it "sends a DELETE request" do
      stub = stub_request(:delete, "https://overturo.com/api/v1/test/123")
             .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

      http_client.delete("/test/123")
      expect(stub).to have_been_requested
    end
  end

  describe "error handling" do
    it "raises AuthenticationError on 401" do
      stub_api(:get, "/test", status: 401, body: { error: "Invalid API key" })

      expect { http_client.get("/test") }.to raise_error(Overturo::AuthenticationError) do |e|
        expect(e.message).to eq("Invalid API key")
        expect(e.http_status).to eq(401)
      end
    end

    it "raises ForbiddenError on 403" do
      stub_api(:get, "/test", status: 403, body: { error: "Forbidden" })
      expect { http_client.get("/test") }.to raise_error(Overturo::ForbiddenError)
    end

    it "raises NotFoundError on 404" do
      stub_api(:get, "/test", status: 404, body: { error: "Not found" })
      expect { http_client.get("/test") }.to raise_error(Overturo::NotFoundError)
    end

    it "raises InvalidRequestError on 400" do
      stub_api(:get, "/test", status: 400, body: { error: "Bad request" })
      expect { http_client.get("/test") }.to raise_error(Overturo::InvalidRequestError)
    end

    it "raises InvalidRequestError on 422" do
      stub_api(:post, "/test", status: 422, body: { error: "Validation failed" })
      expect { http_client.post("/test", body: {}) }.to raise_error(Overturo::InvalidRequestError)
    end

    it "raises RateLimitError on 429" do
      stub_api(:get, "/test", status: 429, body: { error: "Rate limit exceeded" })
      expect { http_client.get("/test") }.to raise_error(Overturo::RateLimitError)
    end

    it "raises ApiError on 500" do
      stub_api(:get, "/test", status: 500, body: { error: "Internal server error" })
      expect { http_client.get("/test") }.to raise_error(Overturo::ApiError)
    end

    it "preserves http_body and json_body on errors" do
      body = { error: "Not found" }
      stub_api(:get, "/test", status: 404, body: body)

      expect { http_client.get("/test") }.to raise_error(Overturo::NotFoundError) do |e|
        expect(e.http_body).to eq(body.to_json)
        expect(e.json_body).to eq({ "error" => "Not found" })
      end
    end
  end

  describe "retry logic" do
    it "retries on 429 when max_retries > 0" do
      config.max_retries = 1

      stub = stub_request(:get, "https://overturo.com/api/v1/test")
             .to_return(
               { status: 429, body: '{"error":"rate limited"}', headers: { "Content-Type" => "application/json" } },
               { status: 200, body: '{"ok":true}', headers: { "Content-Type" => "application/json" } }
             )

      result = http_client.get("/test")
      expect(result).to eq({ "ok" => true })
      expect(stub).to have_been_requested.twice
    end

    it "does not retry on 404" do
      config.max_retries = 2

      stub_api(:get, "/test", status: 404, body: { error: "Not found" })

      expect { http_client.get("/test") }.to raise_error(Overturo::NotFoundError)
    end
  end

  describe "request ID" do
    it "sends X-Request-ID header" do
      stub_api(:get, "/test", body: {})

      http_client.get("/test")

      expect(WebMock).to(have_requested(:get, "https://overturo.com/api/v1/test")
        .with { |req| req.headers["X-Request-Id"]&.start_with?("req_") })
    end

    it "tracks last request ID" do
      stub_api(:get, "/test", body: {})

      http_client.get("/test")

      expect(http_client.last_request_id).to start_with("req_")
    end
  end

  describe "idempotency key" do
    it "sends Idempotency-Key header on POST" do
      stub = stub_request(:post, "https://overturo.com/api/v1/test")
             .to_return(status: 201, body: '{"id":"123"}', headers: { "Content-Type" => "application/json" })

      http_client.post("/test", body: { name: "test" }, idempotency_key: "idem_abc123")

      expect(stub).to have_been_requested
      expect(WebMock).to have_requested(:post, "https://overturo.com/api/v1/test")
        .with(headers: { "Idempotency-Key" => "idem_abc123" })
    end

    it "sends Idempotency-Key header on PATCH" do
      stub_request(:patch, "https://overturo.com/api/v1/test/123")
        .to_return(status: 200, body: '{"id":"123"}', headers: { "Content-Type" => "application/json" })

      http_client.patch("/test/123", body: { name: "x" }, idempotency_key: "idem_xyz")

      expect(WebMock).to have_requested(:patch, "https://overturo.com/api/v1/test/123")
        .with(headers: { "Idempotency-Key" => "idem_xyz" })
    end

    it "does not send Idempotency-Key when not provided" do
      stub_api(:post, "/test", body: {})

      http_client.post("/test", body: {})

      expect(WebMock).to(have_requested(:post, "https://overturo.com/api/v1/test")
        .with { |req| !req.headers.key?("Idempotency-Key") })
    end
  end
end
