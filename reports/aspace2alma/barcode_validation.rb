require 'csv'
require 'json'
require 'net/sftp'
require 'open-uri'
require 'uri'

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

# This class checks if a barcode already exists in Alma based on a
# series of requests to the Alma API.  These requests check a logical
# set that contains all items in SC locations with barcodes.  This way, we can
# avoid adding duplicate barcodes to Alma.
class AlmaSetDuplicateCheck
  def duplicate?(barcode)
    check_variables
    alma_barcodes.include? barcode
  end

  # This struct is responsible for parsing the relevant data from an
  # Alma /sets/{id}/members API json response.
  AlmaMemberSetResponse = Struct.new(:raw_data) do
    def self.from_uri(uri)
      new(uri.open('Accept' => 'application/json').read)
    end

    def total_barcode_count
      data['total_record_count']
    end

    def barcodes
      # barcodes are kept in the "description" field
      data['member']&.map {|item| item['description'] } || []
    end

    private

    def data
      @data ||= JSON.parse raw_data
    end
  end

  private

  def alma_barcodes
    @alma_barcodes ||= begin
      offsets_to_request.each do |offset|
        sleep 1 until can_make_another_request?
        request_threads << Thread.new do
          response = AlmaMemberSetResponse.from_uri uri(offset)
          response.barcodes
        end
      end
      request_threads.map(&:value).flatten.to_set
    end
  end

  def offsets_to_request
    # offsets start with 0, while barcode_counts start with 1.  We subtract one from
    # the barcode count to let it match
    maximum_offset = total_barcode_count - 1
    # For a total_barcode_count of 350 and an alma_page_size of 100,
    # this method would yield: 0, 100, 200, 300
    (0..total_barcode_count).step(alma_page_size)
  end

  def request_threads
    @request_threads ||= []
  end

  def can_make_another_request?
    # Alma only allows 10 API requests per second for all of the
    # PUL sandbox.
    # So we make sure that there are only 5 active request threads
    # at any given time. Each request typically takes 3-7 seconds,
    # so it is quite unlikely that we would have more than 5 requests
    # in any given second, and much more likely that we would have
    # ~1 request/second.
    request_threads.count(&:alive?) < 5
  end

  def total_barcode_count
    @total_barcode_count ||= AlmaMemberSetResponse.from_uri(uri(0)).total_barcode_count
  end

  def uri(offset)
    URI.parse "#{alma_region}/almaws/v1/conf/sets/#{alma_sc_barcodes_set}/members?limit=#{alma_page_size}&offset=#{offset}&apikey=#{api_key}"
  end

  def check_variables
    raise 'Missing the ALMA_CONFIG_API_KEY environment variable; please set it to a valid api key with config read permissions' unless api_key
    raise 'Missing the ALMA_REGION environment variable; please set it to a valid alma region including https://' unless alma_region
    raise 'Missing the ALMA_SC_BARCODES_SET environment variable; please set it to the id of a set containing special collections barcodes' unless alma_sc_barcodes_set
  end

  def alma_region
    ENV.fetch 'ALMA_REGION', nil
  end

  def alma_sc_barcodes_set
    ENV.fetch 'ALMA_SC_BARCODES_SET', nil
  end

  def api_key
    ENV.fetch 'ALMA_CONFIG_API_KEY', nil
  end

  def alma_page_size
    100
  end
end
