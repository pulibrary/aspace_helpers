require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login
start_time = "Process started: #{Time.now}"
puts start_time

output_file = "accessrestrict_mss.csv"
repo = 5

ids = add_ids_to_array(repo, 'resources')
puts "#{ids.count} resources to fetch"

CSV.open(output_file, "w",
         :write_headers => true,
         :headers => ["eadid", "uri", "accessrestrict"]) do |row|
  ids.each_slice(250).with_index(1) do |id_batch, batch_number|
    records = @client.get("repositories/#{repo}/resources", {
                            query: {
                              id_set: id_batch
                            }
                          }).parsed
    records.each do |record|
      eadid = record['ead_id']
      uri = record['uri']
      accessrestricts = record['notes'].select {|note| note['type']=='accessrestrict'}
      accessrestricts.each do |accessrestrict|
        row << [eadid, uri, accessrestrict.dig('subnotes', 0, 'content')]
      end
    end
    puts "Processed #{[batch_number * 250, ids.count].min} of #{ids.count} resources"
  end
end

puts "Process ended #{Time.now}."
