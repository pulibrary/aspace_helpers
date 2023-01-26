require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("TC099_barcodes.csv"), :headers => true)
log = "log_update_top_containers.txt"

csv.each do |row|
  uri = row['uri']
  barcode = row['barcode']
  container = @client.get(uri).parsed
  container['barcode'] = barcode
  post = @client.post(uri, container.to_json)
  response = JSON.parse post.body
  response_parsed = "#{container['ils_holding_id']}:#{response['uri']}:updated with:#{barcode}\n"
  puts response_parsed
  log_entry = response
  File.write(log, log_entry, mode: 'a')
end

puts "Process ended: #{Time.now}" 
