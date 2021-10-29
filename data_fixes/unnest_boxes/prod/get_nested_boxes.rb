require 'archivesspace/client'
require 'json'
require_relative '../../../helper_methods.rb'
start_time = "Process started: #{Time.now}"
puts start_time

aspace_login()

filename = 'get_aos.csv'
repos_all = (3..12).to_a
#repos_all = [11]
aos_to_review = []
top_containers = []

repos_all.each do |repo|
  top_containers << get_all_records_for_repo_endpoint(repo, 'top_containers')
  aos_to_review << get_all_records_for_repo_endpoint(repo, 'archival_objects').select do |ao| #3, 1807
    #aos must have a parent and a subcontainer to be selected.
    ao['parent'] &&
    #index [0] is a hack but we're looking for a known improperly nested box
    ao.dig('instances', 0, 'sub_container')
  rescue Exception => msg
  puts "Gathering records ended at #{Time.now} with error '#{msg.class}: #{msg.message}''"
  end #end get
end #end repos_all.each do
aos_to_review = aos_to_review.flatten!
top_containers = top_containers.flatten!

CSV.open(filename, "wb",
    :write_headers=> true,
    :headers => ["uri", "cid", "unittitle", "unitdate", "top_container_uri", "top_container", "subcontainer"]) do |row|
          aos_to_review.each do |ao|
          #for each top_container, get the descriptive data and subcontainers of type box
            ao['instances'].each do |instance|
              uri = ao['uri']
              cid = ao.dig('ref_id')
              unittitle = ao['title']
              unitdate = ao.dig('dates',0,'expression')
              #check for all subcontainer keys called 'type_\d+' with value 'box'
              unless instance['sub_container'].nil?
                subcontainer_type_pattern = /(type_)(\d+)/ #this is the 'type_2' pattern
                nested_box = instance['sub_container'].find {|k,v| k[subcontainer_type_pattern] && v=="box"}
                if nested_box.nil? == false
                  #get the first box, i.e. the top container uri
                  #do we need to get the top_container record for the box number? or is this sufficient?
                  then
                  top_container_uri = instance.dig('sub_container', 'top_container', 'ref')
                  top_container_match = top_containers.select {|container| container['uri'] == top_container_uri}
                  top_container_string = "#{top_container_match[0]['type']} #{top_container_match[0]['indicator']}"
                  row << [uri, cid, unittitle, unitdate, top_container_uri, top_container_string]
                  #find all nested boxes in that box
                  subcontainer_types = instance['sub_container'].select {|k,v| k[subcontainer_type_pattern] && v=="box"}
                    subcontainer_types.each do |type_pair|
                      #subcontainer_type = type_pair[0] + ': ' + type_pair[1]
                      subcontainer_type_index = type_pair[0].gsub(/\D+/, '')
                      #match each numbered type_ hash to its corresponding indicator_hash via regex
                      #(very hacky, but the best idea I came up with)
                      subcontainer_indicator_logic = instance['sub_container'].select {|k,v| k[/indicator_\d+/] if k.gsub(/\D+/, '') == subcontainer_type_index }
                      #subcontainer_indicator = subcontainer_indicator_logic.keys.join('') + ': ' + subcontainer_indicator_logic.values.join('')
                      subcontainer_string = "#{type_pair[1]}^#{subcontainer_indicator_logic.values.join('')}"
                      row << [uri, cid, unittitle, unitdate, top_container_uri, top_container_string, subcontainer_string]
                    end #end subcontainer_types.each
                  end #end if
              end #end unless
            end #end ao['instances'].each
        end #end aos_to_review.each
      #if something goes wrong, tell me why
      rescue Exception => msg
      puts "Processing gathered records ended at #{Time.now} with error '#{msg.class}: #{msg.message}''"
  end #end CSV.open
puts "Process ended: #{Time.now}"
