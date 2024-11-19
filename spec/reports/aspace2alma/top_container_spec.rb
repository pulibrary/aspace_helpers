# frozen_string_literal: false

require_relative '../../../reports/aspace2alma/top_container'
require 'spec_helper.rb'

RSpec.describe TopContainer do
  let(:container) { JSON.parse(File.read(File.open('spec/fixtures/single_container.json'))) }
  let(:container_instance) { described_class.new(container) }
  it 'can be instantiated' do
    #expect(described_class.new(resource_uri, client, 'file', 'log_out', 'remote_file')).to be
    expect(described_class.new(container))
  end
  it 'has a container' do
    expect(container_instance.container_doc).to be_an_instance_of Hash
  end
  it 'has a location code' do
    expect(container_instance.location_code).to be_an_instance_of String
  end
  it 'has the correct location code' do
    expect(container_instance.location_code).to eq "scarcpph"
  end
end
