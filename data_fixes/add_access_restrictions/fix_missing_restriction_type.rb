require 'archivesspace/client'
require 'json'
require 'csv'
require 'pony'
require_relative '../helper_methods.rb'

aspace_login()

output_file = "#{add_restrictions_log}.csv"
csv = CSV.parse(File.read("accessrestrict_final2csv.csv"), :headers => true)

start_time = "Process started: #{Time.now}"
puts start_time

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

  rescue Exception => msg
  error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
  puts end_time
