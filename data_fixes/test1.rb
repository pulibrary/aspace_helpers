require 'archivesspace/client'
require 'json'
require 'csv'
require 'pony'
require_relative '../helper_methods.rb'

aspace_login()

#declare input file with uri and restriction value
csv = CSV.parse(File.read("accessrestrict_final2csv.csv"), :headers => true)
#declare log file
log = "restrictions_log.txt"
#declare count to keep track of how many records were processed
count = 0
#print time stamp of start time
start_time = "Process started: #{Time.now}"
puts start_time
begin
  #for each line in the input file, go to the uri, set restriction_type to input value, and post
  csv.each do |row|
    record = @client.get(row['uri']).parsed
      record['notes'][0]['rights_restriction']['local_access_restriction_type'] = [row['restriction_type']]
    post = @client.post(row['uri'], record.to_json)
    #write to log
    File.write(log, post.body, mode: 'a')
    #puts post.body
    #increment count
    count = count + 1
  end
  #if there is an error, print out what and when
  #[for next time, we could try a skip-line rescue for NoMethodError]
  rescue Exception => msg
  end_time = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
  records_processed =  "#{count} records processed since last start."
  puts end_time
  puts records_processed
  #Send me an email with start and end time and records processed
  #Pony.mail(:to => 'heberlei@princeton.edu', :body => start_time + ' : ' + end_time + '; ' + records_processed)
end
