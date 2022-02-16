require 'archivesspace/client'
require_relative 'helper_methods.rb'

<<<<<<< Updated upstream
<<<<<<< Updated upstream
aspace_login()
=======
<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
aspace_staging_login()
>>>>>>> Stashed changes

start_time = "Process started: #{Time.now}"
puts start_time



  ao_uri = ["/repositories/3/archival_objects/345918", "/repositories/3/archival_objects/344316",
"/repositories/3/archival_objects/340954", "/repositories/3/archival_objects/341000"]
  #puts ao_uri

  ao_uri.each do |uri|
    #puts uri.class
    get_ao = @client.get(uri).parsed
    #puts get_ao
    top_container = nil
    sub_container = nil
        get_ao.dig('instances').each do |instance|
          top_container_record =
            if instance.dig('sub_container').nil? == false
              @client.get(instance['sub_container']['top_container']['ref']).parsed
              else
                if instance.dig('top_container')
                  @client.get(instance['top_container']['ref']).parsed
                end
            end
          top_container = "#{top_container_record['type']} #{top_container_record['indicator']}"
          sub_container =
            if instance.dig('sub_container').nil? == false
                sub1 = instance['sub_container']['type_2'] + " " + instance['sub_container']['indicator_2']
                unless instance.dig('sub_container', 'type_3').nil?
                  sub2 = instance.dig('sub_container', 'type_3') + instance.dig('sub_container', 'indicator_3')
                end
              "#{sub1} #{sub2}"
            end
          puts "#{get_ao['uri']}, #{get_ao['ref_id']}, #{get_ao['title']}, #{get_ao['dates'][0]['expression']}, #{top_container unless top_container.nil?} #{sub_container unless sub_container.nil?}"

        end #uri.each
      rescue Exception => msg
      end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
      end #get_ao['instances'].each


end_time = "Process ended: #{Time.now}"
puts end_time
=======
aspace_local_login()

record = get_single_archival_object_by_id('2', '58844')
puts record
>>>>>>> Stashed changes
