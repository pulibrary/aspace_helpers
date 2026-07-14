require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login

puts "Process started: #{Time.now}"
#create containers from CSV
csv = CSV.parse(File.read(""), :headers => true)
csv.each do |row|
record =
  {
    jsonmodel_type: "top_container",
    indicator: (row['value']).to_s,
    type: "Item",
    barcode: (row['label']).to_s,
    container_locations: [
      {
        "jsonmodel_type"=>"container_location",
        "start_date"=>"2026-07-01",
        "status"=>"current",
        "ref"=>(row['altrender']).to_s
      }
    ],
    collection: [{"ref"=>row['resource'], "identifier"=>row['eadid']}],
    container_profile: {"ref"=>"/container_profiles/31"},
    restricted: true
  }

  post = @client.post('/repositories/13/top_containers', record)
  puts post.body
end
