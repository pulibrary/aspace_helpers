# frozen_string_literal: false

require_relative '../../../reports/aspace2alma/get_MARCxml'
require 'spec_helper.rb'

RSpec.describe 'regular aspace2alma process' do
  let(:resource_uris) do
    ["/repositories/3/resources/1511", "/repositories/3/resources/1512"]
  end
  let(:sftp_session) { instance_double("Net::SFTP::Session", dir: sftp_dir) }
  let(:sftp_dir) { instance_double("Net::SFTP::Operations::Dir") }
  let(:response) { instance_double("ArchivesSpace::Response") }
  let(:client) { ArchivesSpace::Client.new(ArchivesSpace::Configuration.new(base_uri: 'https://example.com/staff/api')) }
  let(:frozen_time) { Time.utc(2023, 10, 8, 12, 3, 1) }

  after do
    Timecop.return
  end
  before do
    Timecop.freeze(frozen_time)
    stub_aspace_login
    allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    allow(sftp_session).to receive(:download!)
      .with("/alma/aspace/sc_active_barcodes.csv", "spec/fixtures/sc_active_barcodes.csv")
    allow(sftp_session).to receive(:stat)
      .with("/alma/aspace/MARC_out.xml")
    allow(sftp_session).to receive(:stat)
      .with("/alma/aspace/MARC_out_old.xml")
    allow(sftp_session).to receive(:stat)
      .with("/alma/aspace/sc_active_barcodes.csv")
    allow(sftp_session).to receive(:stat)
      .with("/alma/aspace/spec/fixtures/sc_active_barcodes.csv")
    allow(sftp_session).to receive(:stat)
      .with("/alma/aspace/sc_active_barcodes_old.csv")
    allow(sftp_session).to receive(:stat)
      .with("/alma/aspace/spec/fixtures/sc_active_barcodes_old.csv")
    allow(sftp_session).to receive(:remove!)
      .with("/alma/aspace/MARC_out_old.xml")
    allow(sftp_session).to receive(:remove!)
      .with("/alma/aspace/sc_active_barcodes_old.csv")
    allow(sftp_session).to receive(:rename!)
      .with("/alma/aspace/spec/fixtures/sc_active_barcodes.csv", "/alma/aspace/sc_active_barcodes_old.csv")
    allow(sftp_session).to receive(:rename!)
      .with("/alma/aspace/MARC_out.xml", "/alma/aspace/MARC_out_old.xml")
    allow(ArchivesSpace::Client).to receive(:new).and_return(client)
    allow(client).to receive(:login).and_return(client)
    allow(client).to receive(:get).and_call_original
    allow(client).to receive(:get).with("repositories/3/top_containers/search",
      query: { q: "collection_uri_u_sstr:\"/repositories/3/resources/1511\"" }).and_return(response)
    allow(client).to receive(:get).with("repositories/3/top_containers/search",
        query: { q: "collection_uri_u_sstr:\"/repositories/3/resources/1512\"" }).and_return(response)
    allow(response).to receive(:parsed).and_return(JSON.parse(File.read(File.open("spec/fixtures/container_response.json"))))
    stub(:get_all_resource_uris_for_institution)
      .and_return(resource_uris)
    stub(:alma_sftp).with('MARC_out.xml')
  end

  context 'when the connection is stable' do
    before do
      stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1511.xml")
        .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1511.xml')))
      stub_request(:get, "https://example.com/staff/api/repositories/3/top_containers/search?q=collection_uri_u_sstr:%22/repositories/3/resources/1511%22")
        .and_return(status: 200, body: "")
      stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1512.xml")
        .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1512.xml')))
      fetch_and_process_records("spec/fixtures/sc_active_barcodes.csv")
    end

    let(:doc) { Nokogiri::XML(File.open('MARC_out.xml')) }

    context 'when aspace returns multiple records' do
      it 'adds a (PULFA) 035 field' do
        expect(doc.xpath('//marc:datafield[@tag = "035"]/marc:subfield/text()').map(&:to_s))
          .to match_array(["(PULFA)MC001.01", "(PULFA)MC001.02.01"])
      end
    end

    context 'when aspace returns a single record' do
      let(:resource_uris) { ["/repositories/3/resources/1511"] }
      let(:doc_file) { File.open('MARC_out.xml') }
      let(:doc_after_processing_fixture) { File.open(File.join('spec', 'fixtures', 'doc_after_processing.xml')) }

      it 'corrects the data in the 040 field' do
        subfield_b_xpath = '//marc:datafield[@tag = "040"]/marc:subfield[@code = "b"]/text()'
        subfield_e_xpath = '//marc:datafield[@tag = "040"]/marc:subfield[@code = "e"]/text()'
        expect(doc.at(subfield_b_xpath).to_s).to eq('eng')
        expect(doc.at(subfield_e_xpath).to_s).to eq('dacs')
      end
      it 'creates the expected document' do
        expect(FileUtils.compare_file(doc_file, doc_after_processing_fixture)).to be_truthy
      end
    end
  end

  # This expectation was raising an error because there is no `assert_nil` method in this context,
  # Not because it was mimicking the error we were seeing in production
  # I don't think we need to keep this test long-term but it is instructive
  it 'raises an error when you call a method that is not defined' do
    expect(ArchivesSpace::Response).not_to be_nil
    expect { assert_nil(ArchivesSpace::Response) }.to raise_error(NoMethodError)
  end

  context 'when the connection is interrupted during a record retrieval' do
    before do
      stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1511.xml")
        .to_raise(Errno::ECONNRESET)
      stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1512.xml")
        .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1512.xml')))
    end
    it 'retries the record' do
      fetch_and_process_records("spec/fixtures/sc_active_barcodes.csv")
      # Since we are rescuing from this error, it is not actually raised
      # but this was the intermediate step to make sure our test setup was raising the error correctly
      # expect { fetch_and_process_records }.to raise_error(Errno::ECONNRESET)
      expect(a_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1511.xml"))
        .to have_been_made.times(4)
      expect(a_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1512.xml"))
        .to have_been_made.times(1)
    end
  end

  describe '#remove_empty_elements' do
    context 'with empty datafield' do
      let(:node) do
        xml = <<~XML
          <record>
            <datafield ind1=" " ind2=" " tag="049"/>
          </record>
        XML

        Nokogiri::XML(xml)
      end

      it 'removes empty elements' do
        expect(node.children).not_to be_empty
        remove_empty_elements(node)
        expect(node.children).to be_empty
      end
    end
    context 'with non-empty datafield' do
      let(:node) do
        xml = <<~XML
          <record>
            <datafield ind1=" " ind2=" " tag="099">
              <subfield code="a">MC001.01</subfield>
            </datafield>
          </record>
        XML

        Nokogiri::XML(xml)
      end

      it 'does not remove populated elements' do
        expect(node.children).not_to be_empty
        remove_empty_elements(node)
        expect(node.children).not_to be_empty
        expect(node.children.first.content).to eq('MC001.01')
      end
    end
    context 'with mix of empty and non-empty child nodes' do
      let(:node) do
        xml = <<~XML
          <record>
            <datafield ind1=" " ind2=" " tag="099">
              <subfield code="a">MC001.01</subfield>
              <subfield code="b"></subfield>
            </datafield>
          </record>
        XML

        Nokogiri::XML(xml)
      end

      it 'does not remove populated elements' do
        expect(node.children).not_to be_empty
        # newlines are counted as nodes
        expect(node.children.children.count).to eq(3)
        expect(node.children.children[1].children.count).to eq(5)
        remove_empty_elements(node)
        expect(node.children.children.count).to eq(1)
        expect(node.children.children[0].children.count).to eq(1)
        expect(node.children).not_to be_empty
        expect(node.content).to eq('MC001.01')
      end
    end
  end
end
