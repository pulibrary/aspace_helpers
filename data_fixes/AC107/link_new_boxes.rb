require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file
csv = CSV.parse(File.read("link_new_boxes.csv"), :headers => true)
log = "log_link_top_containers_20230214.txt"

csv.each do |row|
  uri = row['ao_uri']
  ao = @client.get(uri).parsed
    ao_instance_uris = []
    #check whether the container is already linked
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
