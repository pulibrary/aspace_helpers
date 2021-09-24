require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'
start_time = "Process started: #{Time.now}"
puts start_time

aspace_staging_login()

log = "log.txt"
#repos_all = (3..12).to_a
repos_all = [10]
aos_to_review = []

repos_all.each do |repo|
  aos_to_review << get_all_records_for_repo_endpoint(repo, 'archival_objects').select do |ao| #3, 1807
    #aos must have a parent and a subcontainer to be selected.
    #ao['parent'] &&
    #index [0] is a hack but we're looking for a known improperly nested box
    ao.dig('instances', 0, 'sub_container')
  rescue Exception => msg
  puts "Gathering records ended at #{Time.now} with error '#{msg.class}: #{msg.message}''"
  end #end get
end #end repos_all.each do
aos_to_review = aos_to_review.flatten!

aos_to_review.each do |ao|
#for each top_container, get subcontainers of type box
  ao['instances'].each do |instance|
    #check for all subcontainer keys called 'type_\d+' with value 'box'
      subcontainer_type_pattern = /(type_)(\d+)/ #this is the 'type_2' pattern
      nested_box = instance['sub_container'].find {|k,v| k[subcontainer_type_pattern] && v=="box"}
      unless nested_box.nil?
          if instance['sub_container'].dig('type_3')
            instance['sub_container']['type_3'] = nil
            instance['sub_container']['indicator_3'] = nil
            instance['sub_container']['type_2'] = nil
            instance['sub_container']['indicator_2'] = nil
          elsif instance['sub_container'].dig('type_2')
            instance['sub_container']['type_2'] = nil
            instance['sub_container']['indicator_2'] = nil
          end
        post = @client.post(ao['uri'], ao.to_json)
        #write to log
        File.write(log, post.body, mode: 'a')
      end
  end #end ao['instances'].each
  #if something goes wrong, tell me why
  rescue Exception => msg
  puts "Processing gathered records ended at #{Time.now} with error '#{msg.class}: #{msg.message}''"
end #end aos_to_review.each
    puts "Process ended: #{Time.now}"
