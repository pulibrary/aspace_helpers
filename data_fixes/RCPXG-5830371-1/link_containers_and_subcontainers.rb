require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file
csv = CSV.parse(File.read("cid_container_mapping.csv"), :headers => true)
log = "log_link_containers_and_subcontainers.txt"

csv.each do |row|
  uri = row['ao_uri']
  ao = @client.get(uri).parsed
    ao['instances'] <<
    {
    "instance_type"=>"mixed_materials",
    "jsonmodel_type"=>"instance",
    "is_representative"=>false,
    "sub_container"=>{
      "lock_version"=>0,
      "indicator_2"=>row['subcontainer_number'],
      "type_2"=>row['subcontainer_type'],
      "jsonmodel_type"=>"sub_container",
      "top_container"=>{"ref"=>row['container_uri']}
      }
    }
  post = @client.post(uri, ao.to_json)
  response = post.body
  puts response
  File.write(log, response, mode: 'a')
  end
puts "Process ended: #{Time.now}"
