require 'archivesspace/client'
require_relative 'helper_methods.rb'


aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

ao_tree = @client.get('/repositories/4/resources/4185/ordered_records').parsed
#/repositories/:repo_id/resources/:id/ordered_records
#get_all_archival_objects_for_resource(4, 4185, ['top_containers'])
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
                unless instance.dig('subcontainer', 'type_3').nil?
                  sub2 = instance.dig('subcontainer', 'type_3') + instance.dig('subcontainer', 'indicator_3')
                end
                "#{sub1} #{sub2}"
            end
            puts "#{get_ao['uri']}, #{get_ao['ref_id']}, #{get_ao['title']}, #{get_ao['dates'][0]['expression']}, #{top_container['type']} #{top_container['indicator']} #{sub_container}"
            end
          end
        end #get_ao['instances'].each
      end #unless
  #end #ao_uri
  #
  # puts get_ao['uri']

  #
  #   end
     # instances = record.dig('instances')
     # puts instances
    # instances.each do |instance|
    #   top_container = if instance['sub_container']
    #                   then instance['sub_container']['top_container']['ref']
    #                   else instance['top_container']['ref']
    #                   end
    #   puts top_container
#end
#end
#end
end_time = "Process ended: #{Time.now}"
puts end_time
