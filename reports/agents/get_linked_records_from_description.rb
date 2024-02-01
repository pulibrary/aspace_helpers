require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_login
puts Time.now

output_file = "linked_records.csv"
records_to_prefetch = ["linked_agents", "subjects"]
repositories = (3..12).to_a
record_types = ["archival_objects", "resources", "events", "accessions", "digital_objects"]

def get_resolved_objects_from_ids(repository_id, input_ids, record_type, linked_record_type_to_prefetch)
    all_records = []
    count_processed_records = 0
    count_ids = input_ids.count
    while count_processed_records < count_ids
        last_record = [count_processed_records+59, count_ids].min
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
    :headers => ["uri", "title", "authority", "role", "relator", "terms", "uri"]) do |row|
    repositories.each do |repo|
        record_types.each do |record_type|
            #get all record id's for the repository
            all_record_ids = @client.get("/repositories/#{repo}/#{record_type}",
                query: {
                  all_ids: true
                }).parsed

            #get all resolved records from id's and select those with linked agents
            records_to_prefetch.each do |prefetch|
              puts "#{Time.now}: resolving repo #{repo}: #{prefetch} linked from #{record_type}"
              all_records = get_resolved_objects_from_ids(repo, all_record_ids, record_type, prefetch)

              #construct CSV row for records
              all_records.map do |record|
                puts "getting #{prefetch} for #{record['uri']...}"
                record[prefetch].each do |linked_record|
                  row << [
                    linked_record['ref'],
                    linked_record['_resolved']['title'],
                    if prefetch == "linked_agents"
                      linked_record['_resolved']['names'].map do |name|
                        "#{name['authority_id']} | #{name['source']}"
                      end.join(';')
                    else
                      linked_record['source']
                    end,
                    linked_record['role'],
                    linked_record['relator'],
                    if prefetch == "linked_agents"
                      if ['archival_objects', 'resources'].include?(record_type)
                        linked_record['terms'].map do |term|
                          "#{term['term']} | #{term['term_type']} | #{term['vocabulary']}"
                        end.join(';')
                      else
                        ''
                      end
                    else
                      linked_record['_resolved']['terms'].map do |term|
                        "#{term['term']} : #{term['term_type']} : #{term['vocabulary']}"
                      end.join(';')
                    end,
                    record['uri']
                  ]
                    end
                end
            end
        end
    end
end

puts Time.now
