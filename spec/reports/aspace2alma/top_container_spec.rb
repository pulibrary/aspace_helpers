# frozen_string_literal: false

require_relative '../../../reports/aspace2alma/top_container'
require 'spec_helper.rb'

RSpec.describe TopContainer do
  let(:container_doc) { '{"collection_uri_u_sstr": ["/repositories/12/resources/1467"]}' }
  let(:container_instance) { described_class.new(container_doc) }
  it 'can be instantiated' do
    #expect(described_class.new(resource_uri, client, 'file', 'log_out', 'remote_file')).to be
    expect(described_class.new(container_doc))
  end
  it 'has a resource uri' do
    expect(container_instance.container_doc).to be_an_instance_of Hash
  end
end
