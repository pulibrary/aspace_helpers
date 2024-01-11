require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

output_file = "agents_all.csv"
agent_types = ["software", "families", "corporate_entities", "people"]
CSV.open(output_file, "w",
         :write_headers => true,
         :headers => ["uri", "record_title", "dates_of_existence", "agent_type", "usage", "occurrence",
                      "primary_name", "rest_of_name", "sort_name", "fuller_form", "name_title", "prefix", "suffix",
                      "use_dates", "authorized", "jurisdiction", "source", "authority_id", "rules"]) do |row|
    #get all ids for person agents
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
        #get relevant fields from full records
        uri = agent['uri']
        record_title = agent['title']
        dates_of_existence = "#{agent['dates_of_existence']['structured_date_range']['begin_date_standardized']}-#{agent['dates_of_existence']['structured_date_range']['begin_date_standardized']}"
        agent_type = agent['jsonmodel_type']
        usage = agent['linked_agent_roles']
        occurrence = agent['used_within_repositories']
        agent['names'].map do |name|
            primary_name = name['primary_name']
            rest_of_name = name['rest_of_name']
            sort_name = name['sort_name']
            fuller_form = name['fuller_form']
            name_title = name['title']
            prefix = name['prefix']
            suffix = name['suffix']
            use_dates = name['use_dates']
            authorized = name['authorized']
            jurisdiction = name['jurisdiction']
            source = name['source']
            authority_id = name['authority_id']
            rules = name['rules']
        puts uri, record_title, dates_of_existence, agent_type, usage, occurrence, primary_name, rest_of_name, sort_name, fuller_form, name_title, prefix, suffix, use_dates, authorized, jurisdiction, source, authority_id, rules
        row << [uri, record_title, dates_of_existence, agent_type, usage, occurrence, primary_name, rest_of_name, sort_name, fuller_form, name_title, prefix, suffix, use_dates, authorized, jurisdiction, source, authority_id, rules]
        end
    end
end

end_time = "Process ended #{Time.now}."
puts end_time
