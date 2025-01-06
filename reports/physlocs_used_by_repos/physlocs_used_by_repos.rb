require 'archivesspace/client'
require 'active_support/all'
require_relative 'helper_methods.rb'
#creates a report of container locations and which repos use them
puts Time.now
@client = aspace_login
#cycle through the repos
repositories = (3..12).to_a
#these are all the locations used by ASpace
locations = @client.get("/locations", {query:
  {
    'all_ids' => true
    }}).parsed
#query container records for their locations
records =
  repositories.map do |repo|
      @client.get("repositories/#{repo.to_s}/top_containers/search", q: locations, timeout: 10000 ).parsed
    end
#create a hash of repo and location used for each container
top_container_location_codes = []
containers =
  records.map do |record|
    record['response']['docs'].select do |container|
    top_container_location_code = container['location_display_string_u_sstr'].nil? ? '' : container['location_display_string_u_sstr'][0].gsub(/(^.+\[)(.+)(\].*)/, '\2')
    top_container_location_codes << {'location' => top_container_location_code, 'repo' => container['repository'].gsub('/repositories/', '') }
  end
end
#tally location codes
group_by_location = top_container_location_codes.group_by { |hash| hash['location'] }.map do |physloc, top_container_location_codes|
  repo = top_container_location_codes.map { |hash| hash['repo']}
  {'physloc' => physloc, 'repo' => repo.tally}
  end
#format results
group_by_location.map {|hash|
  physloc = hash['physloc']
  repos = hash['repo'].map {|k, v| "#{k} (count #{v})"}
puts "#{physloc} : #{repos.join('; ')}"}
puts Time.now
