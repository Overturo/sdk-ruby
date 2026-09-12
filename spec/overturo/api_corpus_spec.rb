# frozen_string_literal: true

require "spec_helper"

RSpec.describe ApiCorpus do
  it "loads a recording from the vendored copy alone (the public package is self-contained)" do
    before = ENV.fetch("OVERTURO_API_CORPUS_DIR", nil)
    ENV["OVERTURO_API_CORPUS_DIR"] = ApiCorpus::VENDORED
    expect(ApiCorpus.dir).to eq(ApiCorpus::VENDORED)
    expect(ApiCorpus.body("Vouches_show").dig("vouch", "id")).to eq("<PREFIX_ID:1>")
  ensure
    ENV["OVERTURO_API_CORPUS_DIR"] = before
  end

  it "widens every path placeholder to one segment and leaves the query free" do
    pattern = ApiCorpus.url_pattern("Vouches_show")
    expect("https://overturo.com/api/v1/vouches/vch_dev_abc123").to match(pattern)
    expect("https://overturo.com/api/v1/vouches/vch_dev_abc123?expand=1").to match(pattern)
    expect("https://overturo.com/api/v1/vouches/a/b").not_to match(pattern)
  end
end
