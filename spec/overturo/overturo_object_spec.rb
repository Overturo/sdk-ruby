# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::OverturoObject do
  subject(:obj) { described_class.new({ "id" => "app_123", "name" => "My App", "status" => "active" }) }

  describe "attribute access" do
    it "supports dot notation" do
      expect(obj.id).to eq("app_123")
      expect(obj.name).to eq("My App")
    end

    it "supports bracket notation with string keys" do
      expect(obj["id"]).to eq("app_123")
    end

    it "supports bracket notation with symbol keys" do
      expect(obj[:id]).to eq("app_123")
    end

    it "returns nil for missing attributes via brackets" do
      expect(obj["nonexistent"]).to be_nil
    end

    it "raises NoMethodError for missing attributes via dot notation" do
      expect { obj.nonexistent }.to raise_error(NoMethodError)
    end
  end

  describe "respond_to_missing?" do
    it "returns true for known attributes" do
      expect(obj.respond_to?(:id)).to be true
    end

    it "returns false for unknown attributes" do
      expect(obj.respond_to?(:nonexistent)).to be false
    end
  end

  describe "nested objects" do
    it "wraps nested hashes as OverturoObject" do
      obj = described_class.new({ "user" => { "id" => "usr_1", "name" => "Alice" } })
      expect(obj.user).to be_a(described_class)
      expect(obj.user.name).to eq("Alice")
    end

    it "wraps arrays of hashes" do
      obj = described_class.new({ "items" => [{ "id" => "1" }, { "id" => "2" }] })
      expect(obj.items).to be_an(Array)
      expect(obj.items.first).to be_a(described_class)
      expect(obj.items.first.id).to eq("1")
    end
  end

  describe "#to_h" do
    it "returns a plain hash" do
      result = obj.to_h
      expect(result).to eq({ "id" => "app_123", "name" => "My App", "status" => "active" })
    end

    it "recursively unwraps nested objects" do
      nested = described_class.new({ "user" => { "name" => "Alice" } })
      expect(nested.to_h).to eq({ "user" => { "name" => "Alice" } })
    end
  end

  describe "#to_json" do
    it "serializes to JSON" do
      json = JSON.parse(obj.to_json)
      expect(json["id"]).to eq("app_123")
    end
  end

  describe "#to_s / #inspect" do
    it "returns a readable string" do
      expect(obj.to_s).to include("app_123")
      expect(obj.inspect).to include("OverturoObject")
    end
  end

  describe "#key? / #keys / #values" do
    it "checks key existence" do
      expect(obj.key?("id")).to be true
      expect(obj.key?("nope")).to be false
    end

    it "returns all keys" do
      expect(obj.keys).to contain_exactly("id", "name", "status")
    end
  end

  describe "symbol key initialization" do
    it "normalizes symbol keys to strings" do
      obj = described_class.new({ id: "123", name: "Test" })
      expect(obj["id"]).to eq("123")
      expect(obj.id).to eq("123")
    end
  end
end
