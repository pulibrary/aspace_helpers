require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

puts "Process started: #{Time.now}"
#create containers from CSV
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/reports/mf_to_be_created.csv"), :headers => true)
csv.each do |row|
record =
  {
    jsonmodel_type: "top_container",
    indicator: "#{row['Call Number']} #{row['Description']}",
    type: "Item",
    barcode: (row['Barcode']).to_s,
    container_locations: [
      {
        "jsonmodel_type"=>"container_location",
        "start_date"=>"2026-03-31",
        "status"=>"current",
        "ref"=>row['Location']
      }
    ],
    collection: [{"ref"=>row['resource'], "identifier"=>row['eadid']}],
    container_profile: {"ref"=>"/container_profiles/31"},
    restricted: true
  }

  post = @client.post('/repositories/8/top_containers', record)
  puts post.body
end
