require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

eadid = "MC001.03-04"
# resource_ids = [1716]
resource_ids = [1717, 1711, 1712, 1713, 1714, 1715, 1716, 1718]
# ACLU MC001.03.xx-MC001.04
# /repositories/3/resources/1717 but this is just an index
# /repositories/3/resources/1711
# /repositories/3/resources/1712
# /repositories/3/resources/1713
# /repositories/3/resources/1714
# /repositories/3/resources/1715
# /repositories/3/resources/1716
# /repositories/3/resources/1718

repo = 3
output_file = "#{eadid}.csv"

CSV.open(output_file, "a",
         :write_headers => true,
         :headers => ["uri", "eadid", "ref_id", "title", "first_date", "level", "has_do?", "container"]) do |row|
  resource_ids.each do |resource_id|
    ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed

    ao_tree['uris'].each do |ao_ref|
      ao_uri = []
      ao_uri << ao_ref['ref'] unless ao_ref.dig('level') == 'collection'
      # puts ao_uri

      ao_uri.each do |uri|
        # puts uri.class
        # puts uri
        get_ao = @client.get(uri).parsed
        ead_id = get_ao.dig('ead_id')
        ref_id = get_ao['ref_id']
        title = get_ao['title']
        date = get_ao['dates'][0]['expression']
        level = get_ao['level']
        top_container = nil
        sub_container = nil
        do_boolean = nil
        get_ao.dig('instances').each do |instance|
          top_container_record =
            if instance.dig('sub_container').nil? == false
              @client.get(instance['sub_container']['top_container']['ref']).parsed
            else
              if instance.dig('top_container')
                @client.get(instance['top_container']['ref']).parsed
              end
            end
          top_container =
            # adding this failsafe after it hiccupped, though I don't fully understand why it's needed
            unless top_container_record.nil?
              "#{top_container_record['type']} #{top_container_record['indicator']}"
            else ""
            end
          sub_container =
            if instance.dig('sub_container').nil? == false
              sub1 = "#{instance.dig('sub_container', 'type_2')} #{instance.dig('sub_container', 'indicator_2')}"
              unless instance.dig('sub_container', 'type_3').nil?
                sub2 = "#{instance.dig('sub_container', 'type_3')} #{instance.dig('sub_container', 'indicator_3')}"
              end
              "#{sub1} #{sub2}"
            end
          do_boolean = instance['instance_type'] == "digital_object"
        end # get_ao['instances'].each
        row << [uri, "#{ead_id ||= ref_id}", title, date, level, "#{if do_boolean then do_boolean else false end}",
                "#{top_container unless top_container.nil?} #{sub_container unless sub_container.nil?}"]
        puts "#{uri}, #{ead_id ||= ref_id}, #{title}, #{date}, #{level}, #{if do_boolean then do_boolean else false end}, #{top_container unless top_container.nil?} #{sub_container unless sub_container.nil?}"

      rescue Exception => msg
        end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
      end # uris.each
    end # csv
  end # tree.each
end # resource_ids.each

end_time = "Process ended: #{Time.now}"
puts end_time
