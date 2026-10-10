# frozen_string_literal: true

require "spec_helper"

# Meetings — the unit of record: window, platform, cancellation, participants
# with their decisions. Every exchange is a recording the real API produced.
RSpec.describe Overturo::Resources::Connect::MeetingConsents do
  let(:client) { test_client }
  let(:meetings) { client.connect.meeting_consents }
  let(:application_id) { "app_abc" }

  describe "#create" do
    it "creates a meeting with a window and reads the meeting-named consent link" do
      stub = ApiCorpus.stub!("Applications_MeetingConsents_create", with_body: true)

      # The recorded request body is what the API accepted (timestamps carry the corpus placeholder).
      result = meetings.create(application_id, ApiCorpus.request("Applications_MeetingConsents_create")["body"])
      expect(stub).to have_been_requested
      expect(result.id).to eq(ApiCorpus.body("Applications_MeetingConsents_create").dig("meeting_consent", "id"))
      expect(result.platform).to eq("zoom")
      expect(result.ends_at).to be_a(String)
      expect(result.participants.total).to eq(0)
      expect(result.consent_link).to be_a(String)
    end
  end

  describe "#list" do
    it "lists the application's meetings with pagination" do
      stub = ApiCorpus.stub!("Applications_MeetingConsents_index")

      result = meetings.list(application_id)
      expect(stub).to have_been_requested
      expect(result.data.size).to eq(ApiCorpus.body("Applications_MeetingConsents_index")["meeting_consents"].size)
      expect(result.data.first.participants.decided).to eq(2)
      expect(result.pagination["per_page"]).to eq(25)
    end
  end

  describe "#retrieve" do
    it "reads one meeting" do
      stub = ApiCorpus.stub!("Applications_MeetingConsents_show")

      result = meetings.retrieve(application_id, "vnsess_1")
      expect(stub).to have_been_requested
      expect(result.status).to eq("checked_in")
      expect(result.cancelled_at).to be_nil
    end
  end

  describe "#update" do
    it "renames and reschedules" do
      stub = ApiCorpus.stub!("Applications_MeetingConsents_update", with_body: true)

      result = meetings.update(application_id, "vnsess_1", ApiCorpus.request("Applications_MeetingConsents_update")["body"])
      expect(stub).to have_been_requested
      expect(result.name).to eq("Corpus Review (moved)")
    end
  end

  describe "#participants" do
    it "lists participants with their decision per purpose" do
      stub = ApiCorpus.stub!("Applications_MeetingConsents_participants")

      result = meetings.participants(application_id, "vnsess_1")
      expect(stub).to have_been_requested
      statuses = result.data.map(&:status)
      expect(statuses).to include("consented", "declined")
      consented = result.data.find { |p| p.status == "consented" }
      expect(consented.decisions.to_h).to include("meeting_recording" => "granted", "ai_transcription" => "declined")
    end
  end

  describe "#cancel" do
    it "cancels the meeting (204)" do
      stub = ApiCorpus.stub!("Applications_MeetingConsents_destroy")

      expect { meetings.cancel(application_id, "vnsess_1") }.not_to raise_error
      expect(stub).to have_been_requested
    end

    it "surfaces a closed meeting as an invalid request" do
      stub_api(:patch, "/applications/#{application_id}/meeting_consents/vnsess_1", status: 409,
                                                                                    body: { error: "This meeting has ended or was cancelled", code: "meeting_closed" })
      expect { meetings.update(application_id, "vnsess_1", title: "x") }.to raise_error(Overturo::Error)
    end
  end
end
