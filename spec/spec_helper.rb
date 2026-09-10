# frozen_string_literal: true

require "simplecov"
require "simplecov-lcov"

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.output_directory = "coverage"
  c.lcov_file_name = "lcov.info"
end

SimpleCov.start do
  enable_coverage :branch
  add_filter %r{^/spec/}
  track_files "lib/**/*.rb"
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
)

require "cvgen"
require "fileutils"
require "tmpdir"
require "pathname"
require "json"
require "yaml"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "tmp/rspec-examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed

  config.before(:suite) do
    FileUtils.mkdir_p(Cvgen::ROOT.join("tmp"))
  end
end
