# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  # RuboCop not available
end

namespace :endpoints do
  desc "Write endpoints.json, the gem's endpoint manifest"
  task :write do
    require "json"
    require_relative "lib/overturo"
    File.write(File.expand_path("endpoints.json", __dir__), "#{JSON.pretty_generate(Overturo::Endpoints.document)}\n")
    puts "endpoints.json: #{Overturo::Endpoints.manifest.size} endpoints"
  end
end

task default: %i[spec]
