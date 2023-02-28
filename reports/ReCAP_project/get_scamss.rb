require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative 'helper_methods.rb'


@client = aspace_login 

resources = get_all_records_for_repo_endpoint(5, 'resources')
CSV.open("mss_linear_feet.csv", "a",
  :write_headers=> true,
  :headers => ["uri", "ead_id", "physloc", "other_physlocs", "linear_feet", "structured_container_count", "unstructured_container_summary"]) do |row|

  resources.each do |resource|
    extents = resource['extents']
    linear_feet = extents.select { |extent| extent['portion'] == 'whole' && extent['extent_type'] == 'linear feet'}
    structured_container_count = extents.select { |extent| extent['portion'] == 'whole' && extent['extent_type'] != 'linear feet'}
    notes = resource['notes']
    physlocs = notes.select { |note| note['type'] == 'physloc'}
    scamss = physlocs.select { |physloc| physloc['content'][0] == 'scamss'}
    other_physlocs = physlocs.select { |physloc| physloc['content'][0] != 'scamss' && physloc['content'][0] !~ /\s/}
    row << [
      resource['uri'],
      resource['ead_id'],
      scamss[0]['content'][0],
      other_physlocs.map { |physloc| physloc['content'][0] }.join(", "),
      "#{linear_feet[0]['number'] unless linear_feet.empty?}",
      "#{structured_container_count[0]['number'] + " " + structured_container_count[0]['extent_type'] unless structured_container_count.empty?}",
      "#{linear_feet[0]['container_summary'] unless linear_feet.empty?}"
    ] unless scamss.empty?
  end

end
