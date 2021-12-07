require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

eadid = "MC147"
resource_id = "1650"
repo = 3
output_file = "#{eadid}.csv"
ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed

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
    top_container = nil
    sub_container = nil
      unless get_ao['instances'].nil?
        get_ao['instances'].each do |instance|
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
              end #unless
              row << [get_ao['uri'], get_ao['ref_id'], get_ao['title'], get_ao['dates'][0]['expression'], "#{top_container unless top_container.nil?} #{sub_container unless sub_container.nil?}"]
              puts "#{get_ao['uri']}, #{get_ao['ref_id']}, #{get_ao['title']}, #{get_ao['dates'][0]['expression']}, #{top_container unless top_container.nil?} #{sub_container unless sub_container.nil?}"

        end #uri.each
      rescue Exception => msg
      end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
      end #get_ao['instances'].each
    end #csv
  end #tree.each

end_time = "Process ended: #{Time.now}"
puts end_time
