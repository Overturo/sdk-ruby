# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::Configuration do
  subject(:config) { described_class.new }

  describe "defaults" do
    it "has nil api_key" do
      expect(config.api_key).to be_nil
    end

    it "has default base_url" do
      expect(config.base_url).to eq("https://overturo.com")
    end

    it "has default api_version" do
      expect(config.api_version).to eq("v1")
    end

    it "has default open_timeout of 30" do
      expect(config.open_timeout).to eq(30)
    end

    it "has default read_timeout of 80" do
      expect(config.read_timeout).to eq(80)
    end

    it "has default write_timeout of 30" do
      expect(config.write_timeout).to eq(30)
    end

    it "has default max_retries of 2" do
      expect(config.max_retries).to eq(2)
    end

    it "has nil logger" do
      expect(config.logger).to be_nil
    end
  end

  describe "#validate!" do
    it "raises when api_key is nil" do
      expect { config.validate! }.to raise_error(Overturo::AuthenticationError)
    end

    it "raises when api_key is empty" do
      config.api_key = ""
      expect { config.validate! }.to raise_error(Overturo::AuthenticationError)
    end

    it "passes when api_key is set" do
      config.api_key = "sk_test_123"
      expect { config.validate! }.not_to raise_error
    end
  end

  describe "overrides" do
    it "allows setting all fields" do
      config.api_key = "sk_test_abc"
      config.base_url = "https://custom.test"
      config.api_version = "v2"
      config.open_timeout = 5
      config.read_timeout = 10
      config.write_timeout = 15
      config.max_retries = 0

      expect(config.api_key).to eq("sk_test_abc")
      expect(config.base_url).to eq("https://custom.test")
      expect(config.api_version).to eq("v2")
      expect(config.open_timeout).to eq(5)
      expect(config.read_timeout).to eq(10)
      expect(config.write_timeout).to eq(15)
      expect(config.max_retries).to eq(0)
    end
  end
end
