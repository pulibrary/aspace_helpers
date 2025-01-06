require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

#AC107.xx collection ids:
file_ids = [2159, 2160]
# file_ids = [2044, 2140, 2141, 2152, 2158, 2159, 2160, 2161, 2162, 2163, 2164, 2142, 2143, 2144, 2145, 2146, 2147]
#endpoint for ao's within a collection:
# /repositories/:repo_id/resources/:id/ordered_records

responses = []
aos = []
file_ids.each do |id|
  #this endpoint returns everything concatenated into one big hash with key 'uris'
  responses << @client.get("/repositories/4/resources/#{id}/ordered_records").parsed
  responses.each do |response|
    response['uris'].each do |uri|
      aos << @client.get(uri['ref']).parsed
      #puts aos
    end #end response['uris'].each
  rescue Exception => msg
  end_time = "Process ended: #{Time.now} with message '#{msg.class}: #{msg.message}''"
  puts end_time
  end #end responses.each
  puts "Finished gathering components of file id #{id} at #{Time.now}."
end #end file_ids.each

#iterate over records, get ao and subcontainer data, then hit the API for each topcontainer
#write everything to csv
CSV.open("AC107_1c.csv", "a",
  :write_headers=> true,
  :headers => ["uri", "ref_id", "level", "title", "instances"]) do |row|
  aos.each do |ao|
      top_containers2csv = ''
      top_containers = unless ao['instances'].nil?
        ao['instances'].each do |instance|
          subcontainer_type = if instance.dig('sub_container', 'type_2') then instance['sub_container']['type_2'] end
          subcontainer_indicator = if instance.dig('sub_container', 'indicator_2') then instance['sub_container']['indicator_2'] end
          unless subcontainer_type.nil?
            subcontainer = "#{subcontainer_type} #{subcontainer_indicator} "
          end #end unless
          unless instance['sub_container']['top_container']['ref'].nil?
            top_container = @client.get(instance['sub_container']['top_container']['ref']).parsed
            top_containers2csv << "#{top_container['uri']}: #{top_container['type']} #{top_container['indicator']} #{subcontainer}; "
          end #end unless
        end #end ao['instances'].each
        puts "#{ao['uri']}, #{ao['ref_id']}, #{ao['level']}, #{ao['title']}, #{top_containers2csv}"
        row << [ao['uri'], ao['ref_id'], ao['level'], ao['title'], top_containers2csv]
      else
        puts "#{ao['uri']}, #{ao['ref_id']}, #{ao['level']}, #{ao['title']}"
        row << [ao['uri'], ao['ref_id'], ao['level'], ao['title']]
      end #end unless
  rescue Exception => msg
  end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
  puts end_time
  end #end aos.each
end #end row builder

puts "Process ended: #{Time.now}"
