# frozen_string_literal: true
require_relative '../../helper_methods'

RSpec.describe 'connection' do
  around do |example|
    cached_aspace_url = ENV['ASPACE_URL']
    ENV['ASPACE_URL'] = 'https://example.com/staff/api'
    cached_aspace_user = ENV['ASPACE_USER']
    ENV['ASPACE_USER'] = 'test_user'
    cached_aspace_pw = ENV['ASPACE_PASSWORD']
    ENV['ASPACE_PASSWORD'] = 'test_pw'
    example.run
    ENV['ASPACE_URL'] = cached_aspace_url
    ENV['ASPACE_USER'] = cached_aspace_user
    ENV['ASPACE_PASSWORD'] = cached_aspace_pw
  end
  before do
    stub_request(:post, "https://example.com/staff/api/users/test_user/login?password=test_pw").
         to_return(status: 200, body: "", headers: {})
  end
  it 'runs a test' do
    aspace_login
  end
end
