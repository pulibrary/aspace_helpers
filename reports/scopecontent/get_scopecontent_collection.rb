require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_login
start_time = "Process started: #{Time.now}"
puts start_time

output_file = "scope_notes.csv"

record_uris = get_all_resource_uris_for_repos([3, 4, 5])

CSV.open(output_file, "a",
         :write_headers => true,
         :headers => ["eadid", "uri", "published", "note", "characters", "bytes"]) do |row|
   record_uris.each do |uri|
    record = @client.get(uri).parsed
    eadid = record['ead_id'] || record['id_0']
    uri = record['uri']
    published = record['publish']
    scopenotes = record['notes'].select {|note| note['type']=='scopecontent'}
    scopenotes.each do |scopenote|
      string = scopenote['subnotes'][0]['content'].gsub(/[\r\n\t]/, ' ')
      row << [eadid, uri, published, string, string.length, string.bytesize]
      #puts "#{eadid}, #{uri}, #{string}, #{string.length}, #{string.bytesize}"
    end 
  end
end

puts "Process ended #{Time.now}."
