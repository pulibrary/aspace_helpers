require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("input_recreate_nested_boxes.csv"), :headers => true)
log = "recreate_nested_boxes_log.txt"

containers_all = get_all_top_container_records_for_institution()
#containers_all = get_all_records_for_repo_endpoint(12, 'top_containers')
existing_container_ids = []
  containers_all.each do |container|
  existing_container_ids << {container['ils_holding_id'] => container['uri']}
end

#construct new container record from csv
top_containers = []
csv.each do |row|
  ils_holding_id = row['ils_holding_id']
  repo = row['repo']
  ao = row['uri']
  cid= row['cid']
  barcode = row['ils_holding_id']
  indicator = row['indicator']
  type = row['type']
  location = row['location']
  restriction = row['restriction']
  top_containers <<
    {
    "barcode"=>"#{barcode}",
    "indicator"=>"#{indicator}",
    "type"=>"#{type}",
    "ils_holding_id"=>"#{ils_holding_id}",
    "repository"=>{"ref"=>"/repositories/#{repo}"},
    "container_locations"=>[{
      #hardcoding current status
      "status"=>"current",
      "start_date"=>"{#{Time.now}}",
      "note"=>"this is a test",
      #hardcoding review location
      "ref"=>"#{location}"}
    ],
    #hardcoding NBox profile
    "container_profile"=>{"ref"=>"/container_profiles/3"},
    "active_restrictions"=>{
      "restriction_note_type"=>"accessrestrict",
      "jsonmodel_type"=>"rights_restriction",
      "local_access_restriction_type"=>["#{restriction}"],
      "linked_records"=>{"ref"=>"#{ao}"}
      }
    }
  end

#check whether the container already exists in ASpace
#if it doesn't, create it
#if it does, return id and uri
top_containers.each do |top_container|
  unless existing_container = existing_container_ids.find { |existing_container| existing_container.has_key?(top_container['ils_holding_id']) }
    repo = top_container['repository']['ref']
    post = @client.post("#{repo}/top_containers", top_container.to_json)
    response = JSON.parse post.body
    response_parsed = "#{top_container['ils_holding_id']}:#{response['uri']}:created\n"
    puts response_parsed
  else no_response = "#{existing_container.keys[0]}:#{existing_container.values[0]}:already exists\n"
    puts no_response
    end
    log_entry = if response then response_parsed else no_response
    File.write(log, log_entry, mode: 'a')
  rescue Exception => msg
  end_time = "Process ended: #{Time.now} with message '#{msg.class}: #{msg.message}''"
  puts end_time
end

puts "Process ended: #{Time.now}"
