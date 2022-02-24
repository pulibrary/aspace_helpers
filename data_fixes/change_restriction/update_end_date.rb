require 'json'
require 'csv'
require 'byebug'

class CSVASpaceRunner
  def initialize(filename, client)
    @csv = CSV.parse(File.read(filename), :headers => true)
    @client = client
    log_filename = "log_#{filename}.txt"
    @log = File.open(log_filename, mode: 'w')
  end
  def run()
    start_time = "Process started: #{Time.now}"
    puts start_time
    @csv.each do |row|
        record = @client.get(row['uri']).parsed
        yield row, record
        post = @client.post(row['uri'], record.to_json)
        #write to log
        @log.write(post.body)
        @log.flush
      rescue Exception => msg
        error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
        puts error
      end
      @log.close
      end_time = "Process ended: #{Time.now}"
      puts end_time
  end
end