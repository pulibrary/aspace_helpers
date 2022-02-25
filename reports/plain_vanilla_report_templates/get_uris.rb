require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time
repo = 3
resource_id = 1718

records = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed
records['uris'].each do |record|
  uri = record['ref']
  full_record = @client.get(uri).parsed
  eadid = full_record['ead_id'] unless full_record['ead_id'].nil?
  cid = full_record['ref_id'] unless full_record['ref_id'].nil?
  puts "#{eadid ||= cid}, #{uri}"
end

puts records

puts "Process ended #{Time.now}."
