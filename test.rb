require 'archivesspace/client'
require 'json'
require_relative 'helper_methods.rb'

aspace_login()

#test dm
# containers = []
# aos << get_single_archival_object_by_id(3, 521187)
# aos.each do |ao|
#   #for each top_container, get the data and ref
#   ao['instances'].each do |instance|
#     puts "#{ao['uri']}
#     #{ao['ref_id']}
#     #{ao['title']}
#     #{ao['dates'][0]['expression']}
#     #{instance['sub_container']['top_container']['ref']}"
#   #for each subcontainer, get data and ref as well as top container
#     pattern = /type_\d+/
#     subcontainers = instance['sub_container'].select {|k,v| k[pattern]}
#     subcontainers.each do |subcontainer|
#       puts "#{ao['uri']}
#       #{ao['ref_id']}
#       #{ao['title']}
#       #{ao['dates'][0]['expression']}
#       #{instance['sub_container']['top_container']['ref']}
#       #{subcontainer[0]}: #{subcontainer[1]}"
#     end
#   end
# end


filename = 'get_aos.csv'
#repos_all = (3..12).to_a
repos_all = [11]
aos_to_review = []
start_time = "Process started: #{Time.now}"
puts start_time

#file_ids.each do |id|
  #aos_to_review << get_all_archival_objects_for_resource(3, id).select do |ao|
repos_all.each do |repo|
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

CSV.open(filename, "wb",
    :write_headers=> true,
    :headers => ["uri", "cid", "unittitle", "unitdate", "top_container", "subcontainer_type", "subcontainer_indicator"]) do |row|
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
                  #get the first box, i.e. the top container
                  then top_container = instance.dig('sub_container', 'top_container', 'ref')
                  row << [uri, cid, unittitle, unitdate, top_container]
                  #get all nested boxes in that box
                  #can I just do nested_box.select here? instead of instance['sub_container']
                  subcontainer_types = instance['sub_container'].select {|k,v| k[subcontainer_type_pattern] && v=="box"}
                    subcontainer_types.each do |type_pair|
                      subcontainer_type = type_pair[0] + ': ' + type_pair[1]
                      subcontainer_type_index = type_pair[0].gsub(/\D+/, '')
                      subcontainer_indicator = instance['sub_container'].select {|k,v| k ': ' v unless k.gsub(/\D+/, '') !== subcontainer_type_index }
                      row << [uri, cid, unittitle, unitdate, top_container, subcontainer_type, subcontainer_indicator]
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
