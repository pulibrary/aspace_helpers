require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_login
start_time = "Process started: #{Time.now}"
puts start_time

record_uris = get_all_resource_uris_for_repos([3, 4, 5])
records = record_uris.each do |record_uri|
  @client.get("#{record_uri}/ordered_records")
end

records['uris'].each do |record|
  uri = record['ref']
  full_record = @client.get(uri).parsed
  eadid = full_record['ead_id'] unless full_record['ead_id'].nil?
  cid = full_record['ref_id'] unless full_record['ref_id'].nil?
  phystechs = record['notes'].select {|note| note['type']=='phystech'}
  phystechs.each do |phystech|
    puts "#{eadid ||= cid}, #{uri}, #{phystech}"
  end
end

puts "Process ended #{Time.now}."
