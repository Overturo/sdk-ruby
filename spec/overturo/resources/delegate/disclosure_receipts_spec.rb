# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Resources::Delegate::DisclosureReceipts do
  let(:client) { test_client }

  describe "#create" do
    it "posts the closed mint payload and unwraps record_id + record" do
      stub_api(:post, "/disclosure_receipts", status: 201, body: {
                 "disclosure_receipt" => {
                   "record_id" => "ct_disc1",
                   "record" => { "record" => { "record_type" => "notice_record" } }
                 }
               })

      receipt = client.delegate_ns.disclosure_receipts.create(
        flow_id: "acc_flow1", agent_id: "agt_1", disclosed_at: "2026-08-06T10:00:00Z", locale: "en"
      )

      expect(receipt.record_id).to eq("ct_disc1")
      expect(receipt.record["record"]["record_type"]).to eq("notice_record")
      expect(a_request(:post, "https://overturo.com/api/v1/disclosure_receipts").with(
               body: hash_including("flow_id" => "acc_flow1", "agent_id" => "agt_1",
                                    "disclosed_at" => "2026-08-06T10:00:00Z", "locale" => "en")
             )).to have_been_made
    end

    it "surfaces the mint's typed 422 shape ({error: message, code: code}) via error_code" do
      stub_api(:post, "/disclosure_receipts", status: 422, body: {
                 "error" => "the named flow does not disclose this agent",
                 "code" => "agent_not_disclosed"
               })

      expect do
        client.delegate_ns.disclosure_receipts.create(
          flow_id: "acc_flow1", agent_id: "agt_other", disclosed_at: "2026-08-06T10:00:00Z"
        )
      end.to raise_error(Overturo::InvalidRequestError) { |e|
        expect(e.error_code).to eq("agent_not_disclosed")
        expect(e.message).to include("does not disclose")
      }
    end

    it "maps the parity-preserving 404 (unknown or foreign flow/agent)" do
      stub_api(:post, "/disclosure_receipts", status: 404,
                                              body: { "error" => "Flow or agent not found" })

      expect do
        client.delegate_ns.disclosure_receipts.create(
          flow_id: "acc_nope", agent_id: "agt_1", disclosed_at: "2026-08-06T10:00:00Z"
        )
      end.to raise_error(Overturo::NotFoundError)
    end

    it "maps the missing-scope 403" do
      stub_api(:post, "/disclosure_receipts", status: 403,
                                              body: { "error" => "Requires disclosures:write scope" })

      expect do
        client.delegate_ns.disclosure_receipts.create(
          flow_id: "acc_flow1", agent_id: "agt_1", disclosed_at: "2026-08-06T10:00:00Z"
        )
      end.to raise_error(Overturo::ForbiddenError)
    end
  end
end
