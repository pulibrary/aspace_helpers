require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_staging_login
puts Time.now
output_file = "linked_agents.csv"

repositories = (12..12).to_a

CSV.open(output_file, "w",
    :write_headers => true,
    :headers => ["agent_uri", "agent_title", "agent_role", "agent_relator", "agent_terms", "record_uri"]) do |row|
    repositories.each do |repo|
        #define resolve parameter
        resolve = ['linked_agents']
        #get all ao id's for the repository
        all_ao_ids = @client.get("/repositories/#{repo}/archival_objects",
            query: {
              all_ids: true
            }).parsed

        #get all resolved ao's from id's and select those with linked agents
        all_aos = []
        count_processed_records = 0
        count_ids = all_ao_ids.count
        while count_processed_records < count_ids
            last_record = [count_processed_records+249, count_ids].min
            all_aos << @client.get("/repositories/#{repo}/archival_objects",
                    query: {
                      id_set: all_ao_ids[count_processed_records..last_record],
                      resolve: resolve
                    }).parsed
            count_processed_records = last_record
        end

        all_aos = all_aos.flatten.select do |ao|
            next if ao['linked_agents'].nil?

            ao['linked_agents'].empty? == false
        end

        # #construct CSV row for ao's
        all_aos.map do |ao|
            ao['linked_agents'].each do |linked_agent|
                row << [linked_agent['ref'], linked_agent['_resolved']['title'], linked_agent['role'], linked_agent['relator'] || '', linked_agent['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';'), ao['uri']]
                puts "#{linked_agent['ref']}, #{linked_agent['_resolved']['title']}, #{linked_agent['role']}, #{linked_agent['relator'] || ''}, #{linked_agent['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';')}, #{ao['uri']}"
            end
        end

        #get all resources for the repository
        all_resource_ids = @client.get("/repositories/#{repo}/resources",
            query: {
              all_ids: true
            }).parsed

        all_resources = []
        count_processed_records = 0
        count_ids = all_resource_ids.count
        while count_processed_records < count_ids
            last_record = [count_processed_records+249, count_ids].min
            all_resources << @client.get("/repositories/#{repo}/resources",
                    query: {
                      id_set: all_resource_ids[count_processed_records..last_record],
                      resolve: resolve
                    }).parsed
            count_processed_records = last_record
        end

        # #get all resolved resources from id's and select those with linked agents
        all_resources = all_resources.flatten.select do |resource|
            next if resource['linked_agents'].nil?

            resource['linked_agents'].empty? == false
        end

        # #construct CSV row for resources
        all_resources.map do |resource|
            resource['linked_agents'].each do |linked_agent|
                row << [linked_agent['ref'], linked_agent['resolved']['title'], linked_agent['role'], linked_agent['relator'], linked_agent['terms'], resource['uri']]
                puts "#{linked_agent['ref']}, #{linked_agent['resolved']['title']}, #{linked_agent['role']}, #{linked_agent['relator']}, #{linked_agent['terms']}, #{resource['uri']}"
            end
        end
    end
end

puts Time.now
