# frozen_string_literal: true

require 'bundler/setup'
require 'tiktok_business_api'
require 'webmock/rspec'

# Configure SimpleCov for code coverage
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
    add_group 'Resources', 'lib/tiktok_business_api/resources'
    add_group 'Core', 'lib/tiktok_business_api'
    # Save JSON format for Codecov
    # Only if running in CI
    if ENV['CI']
      require 'simplecov-json'
      SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clear WebMock stubs after each test
  config.after(:each) do
    WebMock.reset!
  end
end

# Helper method for fixture files
def fixture_path
  File.expand_path('fixtures', __dir__)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def json_fixture(file)
  JSON.parse(fixture(file))
end