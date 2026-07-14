require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login
start_time = "Process started: #{Time.now}"
puts start_time

output_file = "phystech_notes.csv"
repos = [3, 4, 5]

CSV.open(output_file, "w",
         :write_headers => true,
         :headers => ["eadid", "uri", "phystech"]) do |row|
  repos.each do |repo|
    ids = add_ids_to_array(repo, 'resources')
    puts "Repo #{repo}: #{ids.count} resources to fetch"
    ids.each_slice(250) do |id_batch|
      records = @client.get("repositories/#{repo}/resources", {
                              query: {
                                id_set: id_batch
                              }
                            }).parsed
      records.each do |record|
        eadid = record['ead_id']
        uri = record['uri']
        phystechs = record['notes'].select {|note| note['type']=='phystech'}
        phystechs.each do |phystech|
          row << [eadid, uri, phystech.dig('subnotes', 0, 'content')]
        end
      end
    end
  end
end

puts "Process ended #{Time.now}."
