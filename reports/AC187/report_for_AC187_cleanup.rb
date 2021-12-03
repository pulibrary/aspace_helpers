require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

eadid = "AC187"
resource_id = "4185"
output_file = "#{eadid}.csv"
ao_tree = @client.get("/repositories/4/resources/#{resource_id}/ordered_records").parsed
#/repositories/:repo_id/resources/:id/ordered_records
#get_all_archival_objects_for_resource(4, 4185, ['top_containers'])

  CSV.open(output_file, "a",
    :write_headers=> true,
    :headers => ["uri", "ref_id", "title", "first_date", "container"]) do |row|
  ao_tree['uris'].each do |ao_ref|
    ao_uri = []
    ao_uri << ao_ref['ref'] unless ao_ref.dig('level') == 'collection'
    #puts ao_uri

    ao_uri.each do |uri|
      #puts uri.class
      get_ao = @client.get(uri).parsed
      top_containers =
        unless get_ao['instances'].nil?
          get_ao['instances'].each do |instance|
            top_container =
              if instance.dig('sub_container').nil? == false
                then @client.get(instance['sub_container']['top_container']['ref']).parsed
                else
                  if instance.dig('top_container')
                    then @client.get(instance['top_container']['ref']).parsed
                  end
              end
            sub_container =
              if instance.dig('sub_container').nil? == false
                then
                  sub1 = instance['sub_container']['type_2'] + " " + instance['sub_container']['indicator_2']
                  unless instance.dig('sub_container', 'type_3').nil?
                    sub2 = instance.dig('sub_container', 'type_3') + instance.dig('sub_container', 'indicator_3')
                  end
                  "#{sub1} #{sub2}"
              end
              row << [get_ao['uri'], get_ao['ref_id'], get_ao['title'], get_ao['dates'][0]['expression'], "#{top_container['type']} #{top_container['indicator']} #{sub_container}"]
              puts "#{get_ao['uri']}, #{get_ao['ref_id']}, #{get_ao['title']}, #{get_ao['dates'][0]['expression']}, #{top_container['type']} #{top_container['indicator']} #{sub_container}"
            end #unless
          end #uri.each
        rescue Exception => msg
        end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
        end #get_ao['instances'].each
      end #csv
    end #tree.each

end_time = "Process ended: #{Time.now}"
puts end_time
