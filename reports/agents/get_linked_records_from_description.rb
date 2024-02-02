require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_staging_login
puts Time.now

output_file = "linked_records.csv"
record_types_to_prefetch = ["linked_agents", "subjects"]
repositories = (10..12).to_a
record_types = ["archival_objects", "resources", "events", "accessions", "digital_objects"]

def get_resolved_objects_from_ids(repository_id, input_ids, record_type, record_types_to_prefetch)
      all_records = []
      count_processed_records = 0
      count_ids = input_ids.count
      while count_processed_records < count_ids
          last_record = [count_processed_records+29, count_ids].min
          all_records << @client.get("/repositories/#{repository_id}/#{record_type}",
                  query: {
                    id_set: input_ids[count_processed_records..last_record],
                    resolve: record_types_to_prefetch
                  }).parsed
          count_processed_records = last_record
      end
      all_records = all_records.flatten
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
            puts "****************************"
            puts "#{Time.now}: resolving repo #{repo}: #{record_type}"
            puts "****************************"
            all_records = get_resolved_objects_from_ids(repo, all_record_ids, record_type, record_types_to_prefetch)
            #construct CSV row for records
            all_records.map do |record|
            record_types_to_prefetch.map do |record_type_to_prefetch|
                next if (record[record_type_to_prefetch].nil? || 
                  record[record_type_to_prefetch].empty?)
                puts "getting records for #{record['uri']...}"
                record[record_type_to_prefetch].each do |linked_record|
                  row << [
                    linked_record['ref'],
                    linked_record['_resolved']['title'],
                    if record_type_to_prefetch == "linked_agents"
                      linked_record['_resolved']['names'].map do |name|
                        "#{name['authority_id']} | #{name['source']}"
                      end.join(';')
                    else
                      linked_record['source']
                    end,
                    linked_record['role'],
                    linked_record['relator'],
                    if record_type_to_prefetch == "linked_agents"
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
