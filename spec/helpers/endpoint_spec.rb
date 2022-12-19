# frozen_string_literal: true
require_relative '../../helper_methods'
require 'spec_helper.rb'

RSpec.describe 'endpoint methods' do
  let(:get_agent_stub) do
    stub_request(:get, "https://example.com/staff/api/agents/people?id_set=11175&resolve[]=").
      to_return(
        status: 200,
        body: ''
      )
  end

  before do
    stub_aspace_login
    get_agent_stub
  end

  it 'can retrieve an agend by id' do
    aspace_login
    person = get_agent_by_id("people", 11175)
    expect(get_agent_stub).to have_been_requested
  end
end