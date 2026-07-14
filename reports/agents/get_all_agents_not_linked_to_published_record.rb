require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

agent_types = ["software", "families", "corporate_entities", "people"]
#get all ids
agent_ids = {}
agent_types.each do |agent_type|
    @client.get("/agents/#{agent_type}", {
                  query: {
                    all_ids: true
                  }
                }).parsed.map { |id| agent_ids[id] = agent_type }
end
#get full records for agent ids
agent_ids.map do |agent_id, agent_type|
    agent = @client.get("/agents/#{agent_type}/#{agent_id}").parsed
    if agent['is_linked_to_published_record'] == false &&
       agent['linked_agent_roles'].empty? == false
        puts "#{agent['uri']}^#{agent['title']}, #{agent['linked_agent_roles']}"
    end
end

end_time = "Process ended #{Time.now}."
puts end_time
