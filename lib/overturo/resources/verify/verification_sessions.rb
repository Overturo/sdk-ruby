# frozen_string_literal: true

module Overturo
  module Resources
    module Verify
      class VerificationSessions < ApiResource
        include ApiOperations::Create
        include ApiOperations::Retrieve

        RESOURCE_PATH = "/verification_sessions"
        OBJECT_KEY = "verification_session"
        LIST_KEY = "verification_sessions"
      end
    end
  end
end
