require 'archivesspace/client'
require 'json'
require 'csv'
require 'pony'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

log = "log_set_to_open_with_note.csv"
csv = CSV.parse(File.read("set_to_open_with_note.csv"), :headers => true)

  csv.each do |row|
    record = @client.get(row['uri']).parsed
    accessrestrict = record['notes'].select { |note| note["type"] == "accessrestrict" }
    #change restriction type here. Takes an array.
    accessrestrict[0]['rights_restriction']['local_access_restriction_type'] = row['restriction_type']
    #change restriction note here. Takes a string.
    accessrestrict[0]['subnotes'][0]['content'] = row['restriction_note']
    #change the end date here
    accessrestrict[0]['rights_restriction']['end'] = row['end_date']
    post = @client.post(row['uri'], record.to_json)
    #write to log
    File.write(log, post.body, mode: 'a')
    puts post.body
    rescue Exception => msg
    error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
  end

puts "Process ended #{Time.now}."