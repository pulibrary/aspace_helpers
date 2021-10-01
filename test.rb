require 'archivesspace/client'
require 'json'
require_relative 'helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("data_fixes/unnest_boxes/test.csv"), :headers => true)

containers_all = get_all_top_container_records_for_institution()
containers_all_ids = containers_all {|container| container['ils_holding_id']}

csv.each do |row|
  repo = row['repo']
  ao = row['uri']
  cid= row['cid']
  barcode = row['ils_holding_id']
  ils_holding_id = row['ils_holding_id']
  indicator = row['indicator']
  type = row['type']
  location = row['location']
  top_container =
    {
    "barcode"=>"{#{barcode}}",
    "indicator"=>"{#{indicator}}",
    "type"=>"{#{type}}",
    "ils_holding_id"=>"{#{ils_holding_id}}",
    "container_locations"=>[{
      #hardcoding current status
      "status"=>"current",
      "start_date"=>"{#{Time.now}}",
      "note"=>"this is a test",
      #hard-coding review location
      "ref"=>"#{location}"}
    ],
    #hardcoding NBox profile
    "container_profile"=>{"ref"=>"/container_profiles/3"}
    }

    post = if containers_all_ids.include? ils_holding_id
            puts ils_holding_id
          #@client.post('/repositories/12/top_containers', top_container.to_json)
          #puts post.body['uri']
          end
end

puts "Process ended: #{Time.now}"
