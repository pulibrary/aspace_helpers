require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login()
start_time = "Process started: #{Time.now}"
puts start_time

log = "log_delete_linked_pul_agent.txt"
records = get_all_resource_records_for_institution
#records = get_all_records_for_repo_endpoint(12, "resources")
#puts records.class

records.each do |record|
  agents = record['linked_agents']
  uri = record['uri']
  #delete corporate agent 2028 if role set to creator and relator set to collector
  #agent could also be 3961
  #rejection = agents.reject! { |agent| (agent['ref'] == "/agents/corporate_entities/3961" || agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
  inclusion = agents.select { |agent| (agent['ref'] == "/agents/corporate_entities/3961" || agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}

  unless inclusion.nil? && agents.count<=1
        puts "#{uri}^#{record['ead_id']}^#{inclusion}"
    # post = @client.post(uri, record.to_json)
    # response = post.body
    # #puts record
    # puts response
    # File.write(log, response, mode: 'a')
  end
  #puts record
end

end_time = "Process ended: #{Time.now}"
puts end_time
