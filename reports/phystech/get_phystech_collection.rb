require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

@client = aspace_login
start_time = "Process started: #{Time.now}"
puts start_time

output_file = "phystech_notes.csv"

record_uris = get_all_resource_uris_for_repos([3, 4, 5])
records = []
record_uris.each do |uri|
  records << @client.get(uri).parsed
end

CSV.open(output_file, "a",
         :write_headers => true,
         :headers => ["eadid", "uri", "phystech"]) do |row|
  records.each do |record|
    eadid = record['ead_id']
    uri = record['uri']
    phystechs = record['notes'].select {|note| note['type']=='phystech'}
    phystechs.each do |phystech|
      row << [eadid, uri, phystech['subnotes'][0]['content']]
    end
  end
end

puts "Process ended #{Time.now}."
