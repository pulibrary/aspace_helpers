require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

@client = aspace_login

top_containers = @client.get(
  'repositories/5/top_containers/search',
  query: {
    q: 'location_uri_u_sstr:"/locations/23648"'
  }
).parsed['response']['docs']
puts top_containers.count

CSV.open("scamss_repo5_top_containers.csv", "a",
  :write_headers=> true,
  :headers => ["ead_id", "container_profile", "display_string", "uri"]) do |row|
  top_containers.map do |result|
      row << [
        (result['collection_identifier_stored_u_sstr'][0] unless result['collection_identifier_stored_u_sstr'].nil?).to_s,
        (result['container_profile_display_string_u_sstr'][0] unless result['container_profile_display_string_u_sstr'].nil?).to_s,
        result['display_string'],
        result['uri']
      ]
  end
end
