require 'spec_helper.rb'
require_relative '../../../reports/aspace2alma/resource'

RSpec.describe Resource do
  let(:resource_uri) { '/repositories/3/resources/1511' }
  let(:client) { ArchivesSpace::Client.new(ArchivesSpace::Configuration.new(base_uri: 'https://example.com/staff/api')) }
  let(:our_resource) { described_class.new(resource_uri, client, 'file', 'log_out', 'remote_file') }
  it 'can be instantiated' do
    expect(described_class.new(resource_uri, client, 'file', 'log_out', 'remote_file')).to be
  end

  describe '#marc_uri' do
    it 'has a uri' do
      expect(our_resource.marc_uri).to eq('/repositories/3/resources/marc21/1511.xml')
    end

    it 'can be run multiple times on the same resource' do
      expect(our_resource.marc_uri).to eq("/repositories/3/resources/marc21/1511.xml")
      expect(our_resource.marc_uri).to eq("/repositories/3/resources/marc21/1511.xml")
    end
  end

  describe '#marc_record' do
    before do
      stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1511.xml")
        .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1511.xml')))
    end
    it 'gets a marc record from the marc_uri' do
      expect(our_resource.marc_xml).to be_an_instance_of(Nokogiri::XML::Document)
      expect(our_resource.marc_xml.child.name).to eq('collection')
    end
  end
end
