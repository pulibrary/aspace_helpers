require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("input_delete_instance_links.csv"), :headers => true)
log = "log_delete_instance_links.txt"

csv.each do |row|
  #puts row['ao_uri']
  uri = row['ao_uri']
  ao = @client.get(uri).parsed
    #ao['instances'] = []
    ao['instances'].each do |instance|
      unless instance['sub_container'].nil?
        subcontainer_type_pattern = /(type_)(\d+)/ #this is the 'type_2' pattern
        nested_box = instance['sub_container'].find {|k,v| k[subcontainer_type_pattern] && v=="box"}
        if nested_box.nil? == false
          then instance = instance.clear
        end
      end
    end
  post = @client.post(uri, ao.to_json)
  response = post.body
  File.write(log, response, mode: 'a')
  puts response
end
