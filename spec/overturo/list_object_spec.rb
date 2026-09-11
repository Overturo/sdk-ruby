# frozen_string_literal: true

require "spec_helper"

RSpec.describe Overturo::ListObject do
  let(:items) do
    [
      Overturo::OverturoObject.new({ "id" => "1", "name" => "A" }),
      Overturo::OverturoObject.new({ "id" => "2", "name" => "B" })
    ]
  end

  let(:pagination) { { "page" => 1, "per_page" => 25, "total" => 2 } }

  subject(:list) { described_class.new(data: items, pagination: pagination) }

  describe "#data" do
    it "returns the array of items" do
      expect(list.data.size).to eq(2)
      expect(list.data.first.id).to eq("1")
    end
  end

  describe "#each" do
    it "iterates over items" do
      ids = list.map(&:id)
      expect(ids).to eq(%w[1 2])
    end
  end

  describe "Enumerable" do
    it "supports map" do
      names = list.map(&:name)
      expect(names).to eq(%w[A B])
    end

    it "supports select" do
      result = list.select { |item| item.id == "1" }
      expect(result.size).to eq(1)
    end
  end

  describe "#has_more?" do
    it "returns false when all items fit on one page" do
      expect(list.has_more?).to be false
    end

    it "returns true when there are more pages" do
      list = described_class.new(
        data: items,
        pagination: { "page" => 1, "per_page" => 2, "total" => 5 }
      )
      expect(list.has_more?).to be true
    end

    it "returns false on the last page" do
      list = described_class.new(
        data: items,
        pagination: { "page" => 3, "per_page" => 2, "total" => 5 }
      )
      expect(list.has_more?).to be false
    end

    it "returns false when pagination is nil" do
      list = described_class.new(data: items, pagination: nil)
      expect(list.has_more?).to be false
    end
  end

  describe "#empty?" do
    it "returns true for empty list" do
      list = described_class.new(data: [], pagination: {})
      expect(list.empty?).to be true
    end

    it "returns false for non-empty list" do
      expect(list.empty?).to be false
    end
  end

  describe "#size / #length" do
    it "returns the count of items" do
      expect(list.size).to eq(2)
      expect(list.length).to eq(2)
    end
  end

  describe "#auto_paging_each" do
    it "returns an enumerator when no block given" do
      expect(list.auto_paging_each).to be_an(Enumerator)
    end

    it "yields all items from the first page" do
      ids = []
      list.auto_paging_each { |item| ids << item.id }
      expect(ids).to eq(%w[1 2])
    end

    it "fetches subsequent pages" do
      http_client = instance_double(Overturo::HttpClient)
      page2_response = {
        "policies" => [{ "id" => "3", "name" => "C" }],
        "pagination" => { "page" => 2, "per_page" => 2, "total" => 3 }
      }

      allow(http_client).to receive(:get)
        .with("/policies", params: { page: 2 })
        .and_return(page2_response)

      list = described_class.new(
        data: items,
        pagination: { "page" => 1, "per_page" => 2, "total" => 3 },
        http_client: http_client,
        resource_path: "/policies",
        list_key: "policies"
      )

      ids = []
      list.auto_paging_each { |item| ids << item.id }
      expect(ids).to eq(%w[1 2 3])
    end
  end
end
