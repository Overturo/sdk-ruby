# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Client do
  describe "#initialize" do
    it "creates a client with an API key" do
      client = Overturo::Client.new(api_key: "sk_test_123")
      expect(client.config.api_key).to eq("sk_test_123")
    end

    it "uses default base_url" do
      client = Overturo::Client.new(api_key: "sk_test_123")
      expect(client.config.base_url).to eq("https://overturo.com")
    end

    it "allows overriding base_url" do
      client = Overturo::Client.new(api_key: "sk_test_123", base_url: "https://local.test")
      expect(client.config.base_url).to eq("https://local.test")
    end

    it "raises AuthenticationError without an API key" do
      expect { Overturo::Client.new }.to raise_error(Overturo::AuthenticationError)
    end

    it "raises AuthenticationError with empty API key" do
      expect { Overturo::Client.new(api_key: "") }.to raise_error(Overturo::AuthenticationError)
    end

    it "allows configuring timeouts" do
      client = Overturo::Client.new(api_key: "sk_test_123", open_timeout: 10, read_timeout: 20)
      expect(client.config.open_timeout).to eq(10)
      expect(client.config.read_timeout).to eq(20)
    end
  end

  describe "surface accessors" do
    let(:client) { Overturo::Client.new(api_key: "sk_test_123") }

    it "returns typed surface for connect" do
      expect(client.connect).to be_a(Overturo::ConnectSurface)
    end

    it "returns typed surface for consent" do
      expect(client.consent).to be_a(Overturo::ConsentSurface)
    end

    it "returns typed surface for verify" do
      expect(client.verify).to be_a(Overturo::VerifySurface)
    end

    it "returns typed surface for protect" do
      expect(client.protect).to be_a(Overturo::ProtectSurface)
    end

    it "returns typed surface for agree" do
      expect(client.agree).to be_a(Overturo::AgreeSurface)
    end

    it "returns typed surface for delegate_ns" do
      expect(client.delegate_ns).to be_a(Overturo::DelegateSurface)
    end

    it "returns typed surface for comply" do
      expect(client.comply).to be_a(Overturo::ComplySurface)
    end

    it "returns typed surface for core" do
      expect(client.core).to be_a(Overturo::CoreSurface)
    end

    it "all surfaces inherit from SurfaceProxy" do
      expect(client.connect).to be_a(Overturo::SurfaceProxy)
    end

    it "resolves resource classes from surface proxies" do
      expect(client.connect.applications).to be_a(Overturo::Resources::Connect::Applications)
    end

    it "memoizes surface proxy instances" do
      expect(client.connect).to be(client.connect)
    end

    it "memoizes resource instances" do
      expect(client.connect.applications).to be(client.connect.applications)
    end

    it "raises NoMethodError for unknown resources" do
      expect { client.connect.nonexistent_resource }.to raise_error(NoMethodError)
    end
  end
end
