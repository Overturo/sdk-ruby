# frozen_string_literal: true

require "json"
require "webmock"

# Recorded API exchanges, keyed by operationId. The recordings are made against
# the real API and validated against the published OpenAPI document, so a stub
# built from one is the response the client will actually see. Ids, timestamps
# and tokens are placeholders (`<PREFIX_ID:n>`, `2026-01-01T00:00:00Z`, `<TOKEN>`).
#
# The shared corpus is read when this gem sits next to it; the public mirror
# carries the vendored copy under spec/fixtures/api_responses. OVERTURO_API_CORPUS_DIR
# overrides the location (used to prove the vendored copy is self-contained).
module ApiCorpus
  SHARED = File.expand_path("../../../shared/conformance/api_responses", __dir__)
  VENDORED = File.expand_path("../fixtures/api_responses", __dir__)
  BASE = "https://overturo.com"
  PLACEHOLDER = /<[A-Z_]+(?::[^>]*)?>/

  module_function

  def dir
    ENV["OVERTURO_API_CORPUS_DIR"] || (File.directory?(SHARED) ? SHARED : VENDORED)
  end

  def exchange(operation_id, step: nil)
    JSON.parse(File.read(File.join(dir, "#{operation_id}#{".#{step}" if step}.json")))
  end

  def request(operation_id, step: nil)
    exchange(operation_id, step: step).fetch("request")
  end

  def response(operation_id, step: nil)
    exchange(operation_id, step: step).fetch("response")
  end

  def body(operation_id, step: nil)
    response(operation_id, step: step)["body"]
  end

  # A URL regexp for the recorded path with every placeholder widened to one
  # path segment; the query string is left free.
  def url_pattern(operation_id, step: nil)
    path = Regexp.escape(BASE + request(operation_id, step: step).fetch("path")).gsub(PLACEHOLDER, "[^/?]+")
    /\A#{path}(?:\?.*)?\z/
  end

  # Installs the WebMock stub for the recording and returns it, so a spec can
  # `expect(stub).to have_been_requested`. `with_body: true` also matches the
  # recorded request body (as a subset), proving the client sends what the
  # server accepted.
  def stub!(operation_id, step: nil, with_body: false)
    req = request(operation_id, step: step)
    res = response(operation_id, step: step)
    stub = WebMock::API.stub_request(req.fetch("method").downcase.to_sym, url_pattern(operation_id, step: step))
    stub = stub.with(body: WebMock::API.hash_including(req.fetch("body"))) if with_body && req["body"]
    stub.to_return(status: res.fetch("status"), body: res["body"].nil? ? "" : JSON.generate(res["body"]), headers: res.fetch("headers", {}))
  end
end
