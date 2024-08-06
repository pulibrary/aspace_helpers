require 'spec_helper.rb'
require_relative '../../../reports/aspace2alma/resource'

RSpec.describe Resource do
  let(:aspace_request) do
    stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1511.xml")
      .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1511.xml')))
  end
  let(:resource_uri) { '/repositories/3/resources/1511' }
  let(:client) { ArchivesSpace::Client.new(ArchivesSpace::Configuration.new(base_uri: 'https://example.com/staff/api')) }
  let(:our_resource) { described_class.new(resource_uri, client, 'file', 'log_out', 'remote_file') }
  before {aspace_request}
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
    it 'gets a marc record from the marc_uri' do
      expect(our_resource.marc_xml).to be_an_instance_of(Nokogiri::XML::Document)
      expect(our_resource.marc_xml.child.name).to eq('collection')
      expect(aspace_request).to have_been_made.once
    end
  end

  describe 'marc_fields' do
    it 'returns the corresponding MARC field' do
      expect(our_resource.tag008).to be_an_instance_of(Nokogiri::XML::Element)
      expect(our_resource.tag008.content).to eq("221215i19171950xx                  eng d")
    end
  end
end
