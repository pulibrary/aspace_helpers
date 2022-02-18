require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login()
start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("input_uris.csv"), :headers => true)
log = "log_remove_linked_pul_agents.txt"
output_file = "output_remove_linked_pul_agents.csv"

CSV.open(output_file, "a",
         :write_headers => true,
         :headers => ["uri", "eadid", "agent"]) do |row_out|
  csv.each do |row|
    uri = row['uri']
    record = @client.get(uri).parsed
    agents = record['linked_agents']
    uri = record['uri']
#delete corporate agent 2028 if role set to creator and relator set to collector
#agent could also be 3961
#if deleting those agents would leave the resource without agent:
#if there are two agents and both meet the criteria, delete one
#else if there is more than one agent, delete all that meet the criteria
#if there is only one agent, don't delete regardless
    rejection =
      if agents.count==2 and agents.select { |agent| (agent['ref'] == "/agents/corporate_entities/3961" && agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
        then agents.reject! { |agent| (agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
        else
          if agents.count>=1 and agents.select { |agent| (agent['ref'] == "/agents/corporate_entities/3961" || agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
             agents.reject! { |agent| (agent['ref'] == "/agents/corporate_entities/3961" || agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
          end
      end
#test
    # inclusion =
    #   if agents.count==2 and agents.select { |agent| (agent['ref'] == "/agents/corporate_entities/3961" && agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
    #     then agents.select { |agent| (agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
    #     else
    #       if agents.count>=1 and agents.select { |agent| (agent['ref'] == "/agents/corporate_entities/3961" || agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
    #          agents.select { |agent| (agent['ref'] == "/agents/corporate_entities/3961" || agent['ref'] == "/agents/corporate_entities/2028") && agent['role'] == "creator" && agent['relator'] == "col"}
    #       end
    #   end
    unless rejection.nil? && agents.count<=1
          # puts "#{uri}^#{record['ead_id']}^#{inclusion}"
          row_out << [uri, record['ead_id'], rejection]
      post = @client.post(uri, record.to_json)
      response = post.body
      #puts record
      puts response
      File.write(log, response, mode: 'a')
    end
  end
end

end_time = "Process ended: #{Time.now}"
puts end_time
