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

    sftp = instance_double(Net::SFTP::Session).as_null_object
    allow(sftp).to receive(:stat).and_yield(instance_double(Net::SFTP::Response, ok?: true))
    allow(sftp).to receive(:open!).with('/alma/aspace/sc_active_barcodes.csv').and_return(barcode_csv)
    sftp
end

# rubocop:disable RSpec/SpecFilePathFormat
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

        expect(sftp).to have_received(:open!).with('/alma/aspace/sc_active_barcodes.csv').once
    end
end
# rubocop:enable RSpec/SpecFilePathFormat
