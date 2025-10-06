require 'spec_helper'
require_relative '../../../reports/aspace2alma/barcode_validation'

def mock_sftp_environment_variables
    allow(ENV).to receive(:fetch) do |var|
        {
          'SFTP_HOST' => 'my-sftp-host.princeton.edu',
            'SFTP_USERNAME' => 'almauser',
            'SFTP_PASSWORD' => 'supersecretpassword123'
        }[var]
    end
end

def mock_sftp_session
    barcode_csv = StringIO.new(<<~END_BARCODE_CSV)
      Barcode
      barcode123
      barcode456
    END_BARCODE_CSV
    sftp_file_factory_mock = instance_double(Net::SFTP::Operations::FileFactory)
    allow(sftp_file_factory_mock).to receive(:open).with('/alma/aspace/sc_active_barcodes.csv').and_yield barcode_csv

    sftp = instance_double(Net::SFTP::Session).as_null_object
    allow(sftp).to receive(:stat).and_yield(instance_double(Net::SFTP::Response, ok?: true))
    allow(sftp).to receive(:file).and_return(sftp_file_factory_mock)
    sftp
end

# rubocop:disable RSpec/MultipleDescribes
RSpec.describe AlmaReportDuplicateCheck do
    it 'connects to sftp with the correct credentials' do
        mock_sftp_environment_variables
        allow(Net::SFTP).to receive(:start).and_yield mock_sftp_session

        described_class.new.duplicate?('barcode123')

        expect(Net::SFTP).to have_received(:start).with('my-sftp-host.princeton.edu', 'almauser', {password: 'supersecretpassword123'})
    end

    it 'raises an error if credentials are not set' do
        allow(ENV).to receive(:fetch)
        expect { described_class.new.duplicate?('barcode123') }.to raise_error('Missing SFTP credentials, please make sure that the SFTP_HOST, SFTP_USERNAME, and SFTP_PASSWORD variables are set')
    end

    it 'deletes the existing old file' do
        mock_sftp_environment_variables
        sftp = mock_sftp_session
        allow(Net::SFTP).to receive(:start).and_yield sftp

        described_class.new.duplicate?('barcode123')

        expect(sftp).to have_received(:remove!).with('/alma/aspace/sc_active_barcodes_old.csv')
    end

    it 'renames the fresh file' do
        sftp = mock_sftp_session
        mock_sftp_environment_variables
        allow(Net::SFTP).to receive(:start).and_yield sftp

        described_class.new.duplicate?('barcode123')

        expect(sftp).to have_received(:rename!).with('/alma/aspace/sc_active_barcodes.csv', '/alma/aspace/sc_active_barcodes_old.csv')
    end

    it 'can use the fresh file to determine if a barcode is a duplicate' do
        sftp = mock_sftp_session
        mock_sftp_environment_variables
        allow(Net::SFTP).to receive(:start).and_yield sftp

        barcode_validator = described_class.new
        expect(barcode_validator.duplicate?('barcode123')).to be true
        expect(barcode_validator.duplicate?('barcode456')).to be true
        expect(barcode_validator.duplicate?('barcode789')).to be false
    end

    it 'only opens the sftp file once, even if called multiple times' do
        sftp = mock_sftp_session
        mock_sftp_environment_variables
        allow(Net::SFTP).to receive(:start).and_yield sftp

        barcode_validator = described_class.new
        20.times { |i| barcode_validator.duplicate?("barcode#{i}") }

        expect(sftp.file).to have_received(:open).once
    end
end

def mock_alma_api_environment_variables
    allow(ENV).to receive(:fetch) do |var|
        {
          'ALMA_CONFIG_API_KEY' => 'my-key',
          'ALMA_REGION' => 'https://api-na.hosted.exlibrisgroup.com',
          'ALMA_SC_BARCODES_SET' => '43977868370006421'
        }[var]
    end
end

def mock_alma_api_responses
    page1 = stub_request(:get, 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/conf/sets/43977868370006421/members')
            .with(query: {'limit' => 100, 'offset' => 0, 'apikey' => 'my-key'})
            .to_return_json(body: {member: [
                              {id: '23480173760006421', description: 'barcode1a', link: 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs/9940026013506421/holdings/22480173830006421/items/23480173760006421'},
                              {id: '23480173770006421', description: 'barcode1b', link: 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs/9940026013506421/holdings/22480173830006421/items/23480173770006421'}
                            ], total_record_count: 280})
        page2 = stub_request(:get, 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/conf/sets/43977868370006421/members')
                .with(query: {'limit' => 100, 'offset' => 100, 'apikey' => 'my-key'})
                .to_return_json(body: {member: [
                                  {id: '23480184420006421', description: 'barcode2a', link: 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs/9968719913506421/holdings/22480184430006421/items/23480184420006421'}
                                ], total_record_count: 280})
        page3 = stub_request(:get, 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/conf/sets/43977868370006421/members')
                .with(query: {'limit' => 100, 'offset' => 200, 'apikey' => 'my-key'})
                .to_return_json(body: {member: [
                                  {id: '23480192370006421', description: 'barcode3a', link: 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/bibs/9940026083506421/holdings/22480192420006421/items/23480192370006421'}
                                ], total_record_count: 280})
        [page1, page2, page3]
end

RSpec.describe AlmaSetDuplicateCheck do
    it 'makes requests to alma' do
        mock_alma_api_environment_variables
        page1, page2, page3 = mock_alma_api_responses

        described_class.new.duplicate? 'barcode99999'

        # We request this page twice: once to get the total count of barcodes,
        # and once to get the actual barcode data
        assert_requested page1, times: 2
        assert_requested page2
        assert_requested page3
    end

    it 'raises an error if we are missing the api key' do
        expect { described_class.new.duplicate? 'barcode99999' }.to raise_error 'Missing the ALMA_CONFIG_API_KEY environment variable; please set it to a valid api key with config read permissions'
    end

    it 'can use the API to determine if a barcode is a duplicate' do
        mock_alma_api_environment_variables
        mock_alma_api_responses
        duplicate_checker = described_class.new

        expect(duplicate_checker.duplicate?('barcode1a')).to be true
        expect(duplicate_checker.duplicate?('barcode1b')).to be true
        expect(duplicate_checker.duplicate?('barcode2a')).to be true
        expect(duplicate_checker.duplicate?('barcode3a')).to be true
        expect(duplicate_checker.duplicate?('barcode99999')).to be false
    end
end
# rubocop:enable RSpec/MultipleDescribes
