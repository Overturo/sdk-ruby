# frozen_string_literal: true

module Overturo
  class Error < StandardError
    attr_reader :http_status, :http_body, :json_body

    def initialize(message = nil, http_status: nil, http_body: nil, json_body: nil)
      @http_status = http_status
      @http_body = http_body
      @json_body = json_body
      super(message)
    end

    # Machine code from a structured error body, across both authority
    # 422 shapes (spec 180): the receipts read uses {"error" => "<code>",
    # "reason" => <message>}, the disclosure mint uses {"error" =>
    # <message>, "code" => "<code>"}. `code` wins when present; the two
    # shapes are the server's contract, surfaced as-is.
    def error_code
      return nil unless json_body.is_a?(Hash)

      json_body["code"] || json_body["error"]
    end
  end

  # 401
  class AuthenticationError < Error; end
  # 403
  class ForbiddenError < Error; end
  # 404
  class NotFoundError < Error; end
  # 400, 422
  class InvalidRequestError < Error; end
  # 429
  class RateLimitError < Error; end
  # 500+
  class ApiError < Error; end
  # Network errors
  class ConnectionError < Error; end
  # Timeout
  class TimeoutError < Error; end

  # @api private
  ERROR_MAP = {
    400 => InvalidRequestError,
    401 => AuthenticationError,
    403 => ForbiddenError,
    404 => NotFoundError,
    422 => InvalidRequestError,
    429 => RateLimitError
  }.freeze

  # ── OAP denial classes (spec 100-1 §3.1) ────────────────────────────
  # Raised by OAP-protocol failures (authorize, escalate, complete).
  # Carry the structured envelope fields so callers can branch on
  # `denial_category` or rescue the per-category subclass directly.
  class OAPDenied < Error
    attr_reader :reason_code, :failed_bound, :denial_category, :cascade_step, :detail

    def initialize(message = nil, reason_code: nil, failed_bound: nil,
                   denial_category: nil, cascade_step: nil, detail: nil,
                   http_status: nil, http_body: nil, json_body: nil)
      @reason_code = reason_code
      @failed_bound = failed_bound
      @denial_category = denial_category
      @cascade_step = cascade_step
      @detail = detail
      super(message, http_status: http_status, http_body: http_body, json_body: json_body)
    end

    # Build the most-specific subclass for an OAP error envelope.
    # Reason-code dispatch takes precedence over category dispatch so
    # the most specific subclass wins (sub-spec 100-2 sequence
    # denials are trajectory_denied but get their own subclass).
    # @param envelope [Hash] the parsed JSON body (root, not the inner `error`)
    # @param status   [Integer, nil] HTTP status for transport-level matching
    def self.from_envelope(envelope, status: nil)
      err = (envelope || {})["error"] || {}
      target = REASON_CODE_TO_CLASS[err["reason_code"]] ||
               CATEGORY_TO_CLASS.fetch(err["denial_category"], OAPDenied)
      target.new(
        err["message"],
        reason_code: err["reason_code"],
        failed_bound: err["failed_bound"],
        denial_category: err["denial_category"],
        cascade_step: err["cascade_step"],
        detail: err["detail"],
        http_status: status,
        json_body: envelope
      )
    end
  end

  # denial_category == "authorization_denied" — OAuth/DPoP layer failed.
  class OAPAuthorizationDenied < OAPDenied; end
  # denial_category == "intent_denied" — request outside grant bounds.
  class OAPIntentDenied < OAPDenied; end
  # denial_category == "trajectory_denied" — execution history blocked the action.
  class OAPTrajectoryDenied < OAPDenied; end
  # Sub-spec 100-2 — sequence_bounds violation
  # (sequence_prohibited / sequence_missing_predecessor). A trajectory
  # denial with a structural-ordering flavour.
  class OAPSequenceDenied < OAPTrajectoryDenied; end

  OAPDenied::CATEGORY_TO_CLASS = {
    "authorization_denied" => OAPAuthorizationDenied,
    "intent_denied" => OAPIntentDenied,
    "trajectory_denied" => OAPTrajectoryDenied
  }.freeze

  OAPDenied::REASON_CODE_TO_CLASS = {
    "sequence_prohibited" => OAPSequenceDenied,
    "sequence_missing_predecessor" => OAPSequenceDenied
  }.freeze
end
