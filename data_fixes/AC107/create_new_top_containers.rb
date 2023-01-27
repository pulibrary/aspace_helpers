require 'archivesspace/client'
require 'active_support/all'
require 'json'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("AC107_Create_New_Containers.csv"), :headers => true)
log = "log_create_top_containers.txt"

top_containers = []
#get values from the input csv
csv.each do |row|
  #ils_holding_id = row['ils_holding_id']
  @repo = row['repo']
  barcode = row['barcode']
  indicator = row['tc_indicator']
  type = row['tc_type']
  location = row['location_uri']
  profile = row['profile_uri']
  restriction = row['restriction']
  top_containers <<
    {
      "barcode"=>barcode.to_s,
    "indicator"=>indicator.to_s,
    "type"=>type.to_s,
    #{}"ils_holding_id"=>ils_holding_id.to_s,
    "repository"=>{"ref"=>@repo.to_s},
    "container_locations"=>[{
      "status"=>"current",
      "start_date"=>"{#{Time.now}}",
      "ref"=>location.to_s
    }],
     "container_profile"=>{"ref"=>profile.to_s},
     "restricted"=>restriction
    }
  rescue Exception => msg
    puts "Constructing records interrupted: #{Time.now} with message '#{msg.class}: #{msg.message}''"
  end

top_containers.each do |top_container|
    post = @client.post("#{@repo}/top_containers", top_container.to_json)
    response = JSON.parse post.body
    response_parsed = "#{top_container['barcode']}:#{response['uri']}:created\n"
    puts response_parsed
    log_entry = response
    File.write(log, log_entry, mode: 'a')
  rescue Exception => msg
   puts "Container creation ended: #{Time.now} with message '#{msg.class}: #{msg.message}''"
end

puts "Process ended: #{Time.now}"
