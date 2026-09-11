# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Error do
  it "inherits from StandardError" do
    expect(described_class.superclass).to eq(StandardError)
  end

  it "carries http_status, http_body, json_body" do
    error = described_class.new(
      "something went wrong",
      http_status: 500,
      http_body: '{"error":"oops"}',
      json_body: { "error" => "oops" }
    )

    expect(error.message).to eq("something went wrong")
    expect(error.http_status).to eq(500)
    expect(error.http_body).to eq('{"error":"oops"}')
    expect(error.json_body).to eq({ "error" => "oops" })
  end

  describe "error hierarchy" do
    it "AuthenticationError < Error" do
      expect(Overturo::AuthenticationError.superclass).to eq(Overturo::Error)
    end

    it "ForbiddenError < Error" do
      expect(Overturo::ForbiddenError.superclass).to eq(Overturo::Error)
    end

    it "NotFoundError < Error" do
      expect(Overturo::NotFoundError.superclass).to eq(Overturo::Error)
    end

    it "InvalidRequestError < Error" do
      expect(Overturo::InvalidRequestError.superclass).to eq(Overturo::Error)
    end

    it "RateLimitError < Error" do
      expect(Overturo::RateLimitError.superclass).to eq(Overturo::Error)
    end

    it "ApiError < Error" do
      expect(Overturo::ApiError.superclass).to eq(Overturo::Error)
    end

    it "ConnectionError < Error" do
      expect(Overturo::ConnectionError.superclass).to eq(Overturo::Error)
    end

    it "TimeoutError < Error" do
      expect(Overturo::TimeoutError.superclass).to eq(Overturo::Error)
    end
  end

  describe "ERROR_MAP" do
    it "maps HTTP status codes to error classes" do
      expect(Overturo::ERROR_MAP[400]).to eq(Overturo::InvalidRequestError)
      expect(Overturo::ERROR_MAP[401]).to eq(Overturo::AuthenticationError)
      expect(Overturo::ERROR_MAP[403]).to eq(Overturo::ForbiddenError)
      expect(Overturo::ERROR_MAP[404]).to eq(Overturo::NotFoundError)
      expect(Overturo::ERROR_MAP[422]).to eq(Overturo::InvalidRequestError)
      expect(Overturo::ERROR_MAP[429]).to eq(Overturo::RateLimitError)
    end
  end
end

# OAP denial subclass dispatch.
RSpec.describe Overturo::OAPDenied do
  def envelope(**fields)
    {
      "error" => {
        "reason_code" => "scope_not_covered",
        "message" => "demo",
        "oap_ver" => "1.0",
      }.merge(fields.transform_keys(&:to_s))
    }
  end

  describe ".from_envelope" do
    it "dispatches authorization_denied to OAPAuthorizationDenied" do
      err = described_class.from_envelope(
        envelope(reason_code: "dpop_invalid",
                 denial_category: "authorization_denied",
                 cascade_step: 1),
        status: 401
      )
      expect(err).to be_a(Overturo::OAPAuthorizationDenied)
      expect(err).to be_a(Overturo::OAPDenied)
      expect(err.denial_category).to eq("authorization_denied")
      expect(err.cascade_step).to eq(1)
      expect(err.http_status).to eq(401)
    end

    it "dispatches intent_denied to OAPIntentDenied" do
      err = described_class.from_envelope(
        envelope(reason_code: "action_not_allowed",
                 denial_category: "intent_denied",
                 cascade_step: 7),
        status: 403
      )
      expect(err).to be_a(Overturo::OAPIntentDenied)
    end

    it "dispatches trajectory_denied to OAPTrajectoryDenied" do
      err = described_class.from_envelope(
        envelope(reason_code: "value_exceeds_tx_max",
                 denial_category: "trajectory_denied",
                 cascade_step: 10),
        status: 403
      )
      expect(err).to be_a(Overturo::OAPTrajectoryDenied)
      expect(err).not_to be_a(Overturo::OAPSequenceDenied)
    end

    it "falls back to OAPDenied when denial_category is absent" do
      err = described_class.from_envelope(
        envelope(reason_code: "validation_failed"),
        status: 422
      )
      expect(err.class).to eq(Overturo::OAPDenied)
    end

    # ── sequence-code dispatch precedence ──────────────────────────
    %w[sequence_prohibited sequence_missing_predecessor].each do |code|
      it "dispatches #{code} to OAPSequenceDenied" do
        err = described_class.from_envelope(
          envelope(reason_code: code,
                   denial_category: "trajectory_denied",
                   cascade_step: 13,
                   failed_bound: "sequence_bounds"),
          status: 403
        )
        expect(err).to be_a(Overturo::OAPSequenceDenied)
        expect(err).to be_a(Overturo::OAPTrajectoryDenied)
        expect(err).to be_a(Overturo::OAPDenied)
        expect(err.failed_bound).to eq("sequence_bounds")
      end
    end

    it "does NOT downgrade other trajectory_denied codes to OAPSequenceDenied" do
      err = described_class.from_envelope(
        envelope(reason_code: "value_exceeds_tx_max",
                 denial_category: "trajectory_denied",
                 cascade_step: 10),
        status: 403
      )
      expect(err).to be_a(Overturo::OAPTrajectoryDenied)
      expect(err).not_to be_a(Overturo::OAPSequenceDenied)
    end
  end
end
