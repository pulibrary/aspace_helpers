require 'archivesspace/client'
require 'json'
require_relative '../../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("input_file.csv"), :headers => true)
log = "log_create_top_containers.txt"

top_containers = []
#get values from the input csv
csv.each do |row|
  ils_holding_id = row['ils_holding_id']
  repo = row['repo']
  barcode = row['barcode']
  indicator = row['tc_indicator']
  type = row['tc_type']
  location = row['location']
  top_containers <<
    {
    "barcode"=>"#{barcode}",
    "indicator"=>"#{indicator}",
    "type"=>"#{type}",
    "ils_holding_id"=>"#{ils_holding_id}",
    "repository"=>{"ref"=>"/repositories/#{repo}"},
    "container_locations"=>[{
      "status"=>"current",
      "start_date"=>"{#{Time.now}}",
      "ref"=>"#{location}"}
    ],
     "container_profile"=>"#{container_profile}"
    }
  rescue Exception => msg
  end_time = "Constructing records interrupted: #{Time.now} with message '#{msg.class}: #{msg.message}''"
  puts end_time
  end

top_containers.each do |top_container|
    repo = top_container['repository']['ref']
    post = @client.post("#{repo}/top_containers", top_container.to_json)
    response = JSON.parse post.body
    response_parsed = "#{top_container['ils_holding_id']}:#{response['uri']}:created\n"
    puts response_parsed
    log_entry = response
    File.write(log, log_entry, mode: 'a')
  rescue Exception => msg
  end_time = "Container creation ended: #{Time.now} with message '#{msg.class}: #{msg.message}''"
  puts end_time
end

puts "Process ended: #{Time.now}"
