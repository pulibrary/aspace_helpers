require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_staging_login
puts Time.now

output_file = "linked_agents.csv"
prefetch = "linked_agents"
repositories = (3..12).to_a
record_types = ["archival_objects", "resources", "events", "accessions", "digital_objects"]

def get_resolved_objects_from_ids(repository_id, input_ids, record_type, linked_record_type_to_prefetch)
    all_records = []
    count_processed_records = 0
    count_ids = input_ids.count
    while count_processed_records < count_ids
        last_record = [count_processed_records+249, count_ids].min
        @client.get("/repositories/#{repository_id}/#{record_type}",
        query: {
          id_set: input_ids[count_processed_records..last_record],
            resolve: linked_record_type_to_prefetch
        }).parsed
        all_records << @client.get("/repositories/#{repository_id}/#{record_type}",
                query: {
                  id_set: input_ids[count_processed_records..last_record],
                    resolve: [linked_record_type_to_prefetch]
                }).parsed
        count_processed_records = last_record
    end
    all_records = all_records.flatten.select do |record|
        next if record[linked_record_type_to_prefetch].nil?

        record[linked_record_type_to_prefetch].empty? == false
    end
end

CSV.open(output_file, "w",
    :write_headers => true,
    :headers => ["agent_uri", "agent_title", "agent_authority", "agent_role", "agent_relator", "agent_terms", "record_uri"]) do |row|
    repositories.each do |repo|
        record_types.each do |record_type|
            #get all ao id's for the repository
            all_record_ids = @client.get("/repositories/#{repo}/#{record_type}",
                query: {
                  all_ids: true
                }).parsed

            #get all resolved ao's from id's and select those with linked agents
            all_records = get_resolved_objects_from_ids(repo, all_record_ids, record_type, prefetch)

            # #construct CSV row for ao's
            all_records.map do |record|
                record[prefetch].each do |linked_agent|
                    row << [linked_agent['ref'], linked_agent['_resolved']['title'], linked_agent['_resolved']['names'].map do |name|
 name['authority_id']
end.join(';'), linked_agent['role'], linked_agent['relator'], if ['archival_objects', 'resources'].include?(record_type)
  linked_agent['terms'].map do |term|
 "#{term['term']} : #{term['term_type']} : #{term['vocabulary']}"
end.join(';')
                                                              else
  ''
end, record['uri']]
                    puts "#{linked_agent['ref']}, #{linked_agent['_resolved']['title']}, #{linked_agent['_resolved']['names'].map do |name|
 name['authority_id']
end.join(';')}, #{linked_agent['role']}, #{linked_agent['relator']}, #{if ['archival_objects', 'resources'].include?(record_type)
  linked_agent['terms'].map do |term|
    "#{term['term']} : #{term['term_type']} : #{term['vocabulary']}"
end.join(';')
                                                                       else
  ''
end}, #{record['uri']}"
                end
            end
        end
    end
end

puts Time.now
