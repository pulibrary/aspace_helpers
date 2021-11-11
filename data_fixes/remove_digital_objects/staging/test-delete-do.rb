require 'archivesspace/client'
require 'json'
require_relative 'helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("data_fixes/remove_digital_objects/input_delete_dos.csv"), :headers => true)
log = "delete_dos.txt"

csv.each do |row|
  uri = row['uri']
  delete = @client.delete(uri)

  response = delete.body
  puts response
  File.write(log, response, mode: 'a')
  rescue Exception => msg
  puts "Processing failed at #{Time.now} with error '#{msg.class}: #{msg.message}'"
end

puts "Process ended: #{Time.now}"
