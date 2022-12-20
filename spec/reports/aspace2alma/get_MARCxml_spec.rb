# frozen_string_literal: false
require_relative '../../../reports/aspace2alma/get_MARCxml'
require 'spec_helper.rb'
require 'byebug'

RSpec.describe 'regular aspace2alma process' do
  before do
    stub_aspace_login
    stub(:get_all_resource_uris_for_institution)
      .and_return(["/repositories/3/resources/1511", "/repositories/3/resources/1512"])
    stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1511.xml")
      .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1511.xml')))
  end

  it 'runs a test' do
    fetch_and_process_records
  end
end
