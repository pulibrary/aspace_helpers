require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("input_link_new_boxes.csv"), :headers => true)
log = "link_nested_boxes_log.txt"

csv.each do |row|
  puts row['ao_uri']
  uri = row['ao_uri']
  ao = @client.get(uri).parsed
    ao_instance_uris = []
    ao_instance_uris << ao['instances'].each do |instance|
      if instance['subcontainer']
        then instance['subcontainer']['top_container']['ref']
      end
    end
    unless ao_instance_uris.include?(row['container_uri'])
    ao['instances'] <<
      {"instance_type"=>"mixed_materials",
        "jsonmodel_type"=>"instance",
        "sub_container"=>{
          "jsonmodel_type"=>"sub_container",
          "top_container"=>{"ref"=>"#{row['container_uri']}"}
        }
    }
  post = @client.post(uri, ao.to_json)
  response = post.body
  puts response
  File.write(log, response, mode: 'a')
  end
rescue Exception => msg
end_time = "Process ended: #{Time.now} with message '#{msg.class}: #{msg.message}''"
puts end_time
end


puts "Process ended: #{Time.now}"

# "instances"=>[{"lock_version"=>0,
# "created_by"=>"admin",
# "last_modified_by"=>"admin",
# "create_time"=>"2021-01-23T02:09:49Z",
# "system_mtime"=>"2021-01-23T02:09:49Z",
# "user_mtime"=>"2021-01-23T02:09:49Z",
# "instance_type"=>"mixed_materials",
# "jsonmodel_type"=>"instance",
# "is_representative"=>false,
# "sub_container"=>{"lock_version"=>0,
# "created_by"=>"admin",
# "last_modified_by"=>"admin",
# "create_time"=>"2021-01-23T02:09:49Z",
# "system_mtime"=>"2021-01-23T02:09:49Z",
# "user_mtime"=>"2021-01-23T02:09:49Z",
# "jsonmodel_type"=>"sub_container",
# "top_container"=>{"ref"=>"/repositories/3/top_containers/31949"}}}]
