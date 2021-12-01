require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("delete_restrictions_5.csv"), :headers => true)
log = "log_delete_restrictions_5.txt"

csv.each do |row|
  uri = row['self_uri']
  ao = @client.get(uri).parsed

notes = ao.dig('notes')
notes.delete_if { |note| note["type"] == "accessrestrict" }
post = @client.post(uri, ao.to_json)
response = post.body
puts response
File.write(log, response, mode: 'a')

rescue Exception => msg
puts "Processing failed at #{Time.now} with error '#{msg.class}: #{msg.message}'"
end #row
