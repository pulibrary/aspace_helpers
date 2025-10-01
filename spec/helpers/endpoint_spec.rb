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

  it 'can retrieve an agent by id' do
  stub_request(:get, "https://example.com/staff/api/agents/people/11175").
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'User-Agent'=>'ArchivesSpaceClient/0.4.1',
       	  'X-Archivesspace-Session'=>'session'
           }).
         to_return(status: 200, body: "", headers: {})
  end
end
