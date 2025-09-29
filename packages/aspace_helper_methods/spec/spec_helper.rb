# frozen_string_literal: true

require "aspace_helper_methods"
require "webmock/rspec"

def stub_aspace_login
  allow(ENV).to receive(:[]).and_call_original
  allow(ENV).to receive(:[]).with("ASPACE_URL").and_return("https://example.com/staff/api")
  allow(ENV).to receive(:[]).with("ASPACE_USER").and_return("test_user")
  allow(ENV).to receive(:[]).with("ASPACE_PASSWORD").and_return("test_pw")
  stub_request(:post, "https://example.com/staff/api/users/test_user/login?password=test_pw")
    .to_return(
      status: 200,
      body: { "session" => "some_long_hash" }.to_json
    )
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
