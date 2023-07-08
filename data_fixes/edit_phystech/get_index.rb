require 'archivesspace/client'
require_relative '../../helper_methods'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

repos = (5..5).to_a
repos.each do |repo|
  #get resource ids
  resource_ids = @client.get("/repositories/#{repo}/resources", {
    query: {
     all_ids: true
   }}).parsed

#find the index of the last processed record by id
  puts resource_ids.find_index(2753)
end
end_time = "Process ended: #{Time.now}"
puts end_time
