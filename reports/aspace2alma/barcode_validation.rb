require 'csv'
require 'net/sftp'

# This class checks if a barcode already exists in Alma based on a
# report from Alma analytics fetched via SFTP.  This way, we can
# avoid adding duplicate barcodes to Alma.
class AlmaReportDuplicateCheck
    def duplicate?(barcode)
        alma_barcodes.include? barcode
    end

  private

    def alma_barcodes
        @alma_barcodes ||= begin
            check_sftp_credentials
            barcodes_from_report = barcodes_from_sftp
            raise 'Could not download barcodes from sftp, stopping.' unless barcodes_from_report

            barcodes_from_report
        end
    end

    def barcodes_from_sftp
        barcodes_from_report = nil
            Net::SFTP.start(ENV.fetch('SFTP_HOST', nil), ENV.fetch('SFTP_USERNAME', nil), {password: ENV.fetch('SFTP_PASSWORD', nil)}) do |sftp|
                sftp.stat(old_report_path) do |response|
                    sftp.remove!(old_report_path) if response.ok?
                end
                sftp.stat(fresh_report_path) do |response|
                    if response.ok?
                        barcodes_from_report = safely_read_report(sftp)
                    end
                end
            end
            barcodes_from_report
    end

    # #rename barcodes report after reading the file:
    # #this will keep the process from running if
    # #either the fresh report from Alma does not arrive
    # #or the ASpace export fails
    def safely_read_report(sftp)
        raw = sftp.file.open(fresh_report_path, &:read)
        parsed = CSV.parse(raw, headers: true)
        barcodes_from_report = parsed&.to_set {|row| row[0]}
        sftp.rename!(fresh_report_path, old_report_path)
        barcodes_from_report
    end

    def check_sftp_credentials
        raise 'Missing SFTP credentials, please make sure that the SFTP_HOST, SFTP_USERNAME, and SFTP_PASSWORD variables are set' unless ENV.fetch('SFTP_HOST', nil) && ENV.fetch('SFTP_USERNAME', nil) && ENV.fetch('SFTP_PASSWORD')
    end

    def fresh_report_path
        '/alma/aspace/sc_active_barcodes.csv'
    end

    def old_report_path
        '/alma/aspace/sc_active_barcodes_old.csv'
    end
end
