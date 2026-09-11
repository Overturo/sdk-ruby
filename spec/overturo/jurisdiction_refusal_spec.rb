# frozen_string_literal: true

require "spec_helper"

# This SDK declares no jurisdiction (it has no authorize surface), but
# it surfaces a jurisdiction refusal via the existing OAPDenied#failed_bound,
# distinct from a transport-level denial that carries no bound.
RSpec.describe "jurisdiction refusal" do
  it "surfaces a jurisdiction refusal via OAPDenied#failed_bound" do
    refusal = Overturo::OAPDenied.from_envelope(
      {
        "error" => {
          "reason_code" => "jurisdiction_not_permitted",
          "failed_bound" => "jurisdiction_bounds",
          "message" => "not allowed in that country"
        }
      }
    )

    expect(refusal).to be_a(Overturo::OAPDenied)
    expect(refusal.reason_code).to eq("jurisdiction_not_permitted")
    expect(refusal.failed_bound).to eq("jurisdiction_bounds")
  end

  it "is distinct from a transport-level denial that carries no bound" do
    transport = Overturo::OAPDenied.from_envelope(
      { "error" => { "reason_code" => "grant_expired", "message" => "expired" } }
    )

    expect(transport.failed_bound).to be_nil
  end
end
