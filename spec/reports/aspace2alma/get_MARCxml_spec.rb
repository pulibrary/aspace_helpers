# frozen_string_literal: false

require_relative '../../../reports/aspace2alma/get_MARCxml'
require 'spec_helper.rb'

RSpec.describe 'regular aspace2alma process' do
  before do
    stub_aspace_login
    stub(:get_all_resource_uris_for_institution)
      .and_return(resource_uris)
    stub(:alma_sftp).with('MARC_out.xml')
    stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1511.xml")
      .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1511.xml')))
    stub_request(:get, "https://example.com/staff/api/repositories/3/resources/marc21/1512.xml")
      .and_return(status: 200, body: File.read(File.open('spec/fixtures/marc_1512.xml')))
    fetch_and_process_records
  end

  let(:doc) { Nokogiri::XML(File.open('MARC_out.xml')) }
  let(:resource_uris) do
    ["/repositories/3/resources/1511", "/repositories/3/resources/1512"]
  end

  context 'when aspace returns multiple records' do
    it 'adds a (PULFA) 035 field' do
      expect(doc.xpath('//marc:datafield[@tag = "035"]/marc:subfield/text()').map(&:to_s))
        .to match_array(["(PULFA)MC001.01", "(PULFA)MC001.02.01"])
    end
  end

  context 'when aspace returns a single record' do
    let(:resource_uris) { ["/repositories/3/resources/1511"] }

    it 'corrects the data in the 040 field' do
      subfield_b_xpath = '//marc:datafield[@tag = "040"]/marc:subfield[@code = "b"]/text()'
      subfield_e_xpath = '//marc:datafield[@tag = "040"]/marc:subfield[@code = "e"]/text()'
      expect(doc.at(subfield_b_xpath).to_s).to eq('eng')
      expect(doc.at(subfield_e_xpath).to_s).to eq('dacs')
    end
  end

  it 'raises an error when the connection is interrupted' do
    expect(ArchivesSpace::Response).not_to be_nil
    expect { assert_nil(ArchivesSpace::Response) }.to raise_error(Exception)
  end
end

#Errno::ECONNRESET
