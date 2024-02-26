require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_login
puts Time.now

output_file = "linked_records.csv"
repositories = (11..12).to_a
record_types = ["resources", "archival_objects"]
record_types_to_prefetch = []

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

# CSV.open(output_file, "w",
#     :write_headers => true,
#     :headers => ["uri", "eadid or cid", "linked_agents", "linked_containers", "linked_digital_objects", "linked_events", "linked_accessions", "linked_deaccessions", "linked_subjects", "uri"]) do |row|
    repositories.each do |repo|
        @linked_agents = []
        @linked_instances = []
        record_types.each do |record_type|
            #get all record id's for the repository
            all_record_ids = @client.get("/repositories/#{repo}/#{record_type}",
                query: {
                  all_ids: true
                }).parsed

            #get all resolved records from id's and select those with linked agents
            all_records = get_resolved_objects_from_ids(repo, all_record_ids, record_type, record_types_to_prefetch)
            #construct CSV row for records
            all_records.each do |record|
                resource_uri = 
                    unless record['resource'].nil?
                        record['resource']['ref']
                    else record['uri']
                    end
                @linked_agents <<
                    record['linked_agents'].map do |agent|
                       {resource_uri => agent['ref']}
                    end unless record['linked_agents'].empty?
                @linked_instances << 
                    record['instances'].map do |instance|
                        {resource_uri => instance.dig('sub_container', 'top_container', 'ref') || instance['ref']}
                    end unless record['instances'].empty?
                # puts record['uri']
                # puts record['ead_id'] || record['ref_id']     
            end
        end

        @linked_agents_grouped = 
            @linked_agents.flatten.group_by { |hash| hash.keys }.map do |key,values|
                {key.join('') => values.map { |value_hash| value_hash.values.join('')}}
            end
        @linked_instances_grouped = 
            @linked_instances.flatten!.group_by { |hash| hash.keys }.map do |key,values|
                {key.join('') => values.map { |value_hash| value_hash.values.join('')}}
            end
            
        puts "linked_agents: #{@linked_agents_grouped}"
        puts "instances: #{@linked_instances_grouped}"   
    end
# end

puts Time.now
