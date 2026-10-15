# frozen_string_literal: true

require "cgi"

module Overturo
  module Resources
    module Consent
      # 201 — consent records captured outside Overturo's surfaces: the Record
      # API (create = capture + commit in one call, idempotent on your key),
      # the read, the batch import with its dry run, and the status read by
      # the subject reference you supplied (email or your own identifier).
      class ConsentRecords < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve

        RESOURCE_PATH = "/consent_records"
        OBJECT_KEY = "consent_record"
        LIST_KEY = "consent_records"

        # 193 D12 — endpoints built by explicit http_client calls below.
        declare_endpoint :post, "<resource>/imports"
        declare_endpoint :get, "<resource>/imports/{import_id}"
        declare_endpoint :get, "/applications/{application_id}/consent_status"

        # Import consents you already hold (at most 5000 rows per batch).
        # Returns the import (status pending); read it with #import_status.
        def import(flow_id:, records:, dry_run: false, send_receipts: false)
          raise ArgumentError, "flow_id is required" if flow_id.nil? || flow_id.to_s.empty?
          raise ArgumentError, "records must be a non-empty array" unless records.is_a?(Array) && records.any?

          response = http_client.post("#{resource_path}/imports",
                                      body: { flow_id: flow_id, records: records, dry_run: dry_run, send_receipts: send_receipts })
          unwrap(response, "import")
        end

        def import_status(import_id)
          raise ArgumentError, "import_id is required" if import_id.nil? || import_id.to_s.empty?

          unwrap(http_client.get("#{resource_path}/imports/#{CGI.escape(import_id.to_s)}"), "import")
        end

        # The per-purpose consent status for a subject reference.
        def status(application_id:, email: nil, external_id: nil)
          raise ArgumentError, "application_id is required" if application_id.nil? || application_id.to_s.empty?
          raise ArgumentError, "email or external_id is required" if email.to_s.empty? && external_id.to_s.empty?

          # Flat bracket keys: the query is `subject[email]=…`, the shape the server reads.
          params = {}
          params["subject[email]"] = email unless email.to_s.empty?
          params["subject[external_id]"] = external_id unless external_id.to_s.empty?
          response = http_client.get("/applications/#{CGI.escape(application_id.to_s)}/consent_status", params: params)
          OverturoObject.new(response)
        end
      end
    end
  end
end
