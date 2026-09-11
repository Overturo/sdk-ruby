# frozen_string_literal: true

module Overturo
  class Client
    attr_reader :config

    def initialize(api_key: nil, base_url: nil, api_version: nil,
                   open_timeout: nil, read_timeout: nil, write_timeout: nil,
                   max_retries: nil, logger: nil)
      @config = Configuration.new
      @config.api_key = api_key if api_key
      @config.base_url = base_url if base_url
      @config.api_version = api_version if api_version
      @config.open_timeout = open_timeout if open_timeout
      @config.read_timeout = read_timeout if read_timeout
      @config.write_timeout = write_timeout if write_timeout
      @config.max_retries = max_retries if max_retries
      @config.logger = logger if logger

      @config.validate!
      @http_client = HttpClient.new(@config)
    end

    def connect
      @connect ||= ConnectSurface.new(@http_client)
    end

    def consent
      @consent ||= ConsentSurface.new(@http_client)
    end

    def verify
      @verify ||= VerifySurface.new(@http_client)
    end

    def protect
      @protect ||= ProtectSurface.new(@http_client)
    end

    def agree
      @agree ||= AgreeSurface.new(@http_client)
    end

    def delegate_ns
      @delegate_ns ||= DelegateSurface.new(@http_client)
    end

    def comply
      @comply ||= ComplySurface.new(@http_client)
    end

    def core
      @core ||= CoreSurface.new(@http_client)
    end
  end

  class SurfaceProxy
    def initialize(http_client)
      @http_client = http_client
      @resources = {}
    end

    private

    def resource(klass)
      @resources[klass] ||= klass.new(@http_client)
    end
  end

  class CoreSurface < SurfaceProxy
    def me
      resource(Resources::Core::Me)
    end

    def accounts
      resource(Resources::Core::Accounts)
    end
  end

  class ConnectSurface < SurfaceProxy
    def applications
      resource(Resources::Connect::Applications)
    end

    def webhooks
      resource(Resources::Connect::Webhooks)
    end

    def connections
      resource(Resources::Connect::Connections)
    end

    def flows
      resource(Resources::Connect::Flows)
    end

    # 126-SX-5 — data portability (CB-4 Art. 20).
    def portability
      resource(Resources::Connect::Portability)
    end
  end

  class ConsentSurface < SurfaceProxy
    def consent_sessions
      resource(Resources::Consent::ConsentSessions)
    end

    # 189 — pre-flight disclosure discovery (publishable-key-scoped).
    def decisions
      resource(Resources::Consent::Decisions)
    end

    def entitlements
      resource(Resources::Consent::Entitlements)
    end

    def trust_levels
      resource(Resources::Consent::TrustLevels)
    end
  end

  class VerifySurface < SurfaceProxy
    def credentials
      resource(Resources::Verify::Credentials)
    end

    def verification_sessions
      resource(Resources::Verify::VerificationSessions)
    end

    def presentations
      resource(Resources::Verify::Presentations)
    end

    def trust_scores
      resource(Resources::Verify::TrustScores)
    end

    def vouches
      resource(Resources::Verify::Vouches)
    end
  end

  class ProtectSurface < SurfaceProxy
    def policies
      resource(Resources::Protect::Policies)
    end

    def data_requests
      resource(Resources::Protect::DataRequests)
    end

    def transfers
      resource(Resources::Protect::Transfers)
    end

    def data_licenses
      resource(Resources::Protect::DataLicenses)
    end
  end

  class AgreeSurface < SurfaceProxy
    def agreements
      resource(Resources::Agree::Agreements)
    end

    def quorum_requests
      resource(Resources::Agree::QuorumRequests)
    end

    def collaborations
      resource(Resources::Agree::Collaborations)
    end
  end

  class DelegateSurface < SurfaceProxy
    def delegations
      resource(Resources::Delegate::Delegations)
    end

    def agent_identities
      resource(Resources::Delegate::AgentIdentities)
    end

    def security_event_streams
      resource(Resources::Delegate::SecurityEventStreams)
    end

    def authorization_receipts
      resource(Resources::Delegate::AuthorizationReceipts)
    end

    def disclosure_receipts
      resource(Resources::Delegate::DisclosureReceipts)
    end
  end

  class ComplySurface < SurfaceProxy
    def anchors
      resource(Resources::Comply::Anchors)
    end

    def evidence_packages
      resource(Resources::Comply::EvidencePackages)
    end

    def clean_rooms
      resource(Resources::Comply::CleanRooms)
    end

    # 126-SX-5 — cross-border transfer register (124) + residency posture (117).
    def transfer_register
      resource(Resources::Comply::TransferRegister)
    end

    def residency_posture
      resource(Resources::Comply::ResidencyPosture)
    end
  end
end
