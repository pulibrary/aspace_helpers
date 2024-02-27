require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_login
puts Time.now

output_file = "linked_records.csv"
repositories = (11..12).to_a
record_types = ["resources", "archival_objects"]
record_types_to_prefetch = []

def count_of_links(array)
    # array.flatten.map { |group| group.map {|k,v| {k=>v.length}}}.flatten
    array.map {|k,v| {k=>v.length}}.flatten
end

def group_array_of_hashes(array)
    array.flatten.group_by { |hash| hash.keys }.map do |key,values|
        {key.join('') => values.map { |value_hash| value_hash.values.join('')}}
    end
end

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
        @report = []
        @linked_aos = []
        @linked_agents = []
        @linked_instances = []
        @linked_digital_objects = []
        @linked_top_containers = []
        @eadids = {}
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
                @eadids.store("#{resource_uri}",  record['ead_id']) if record['resource'].nil?
                @linked_aos << {resource_uri => record['uri']} unless record['resource'].nil?
                @linked_agents << 
                    record['linked_agents'].map do |agent|
                       {resource_uri => agent['ref']}
                    end unless record['linked_agents'].empty?
                @linked_instances << 
                    record['instances'].map do |instance|
                        {resource_uri => instance.dig('sub_container', 'top_container', 'ref') || instance['ref']}
                    end unless record['instances'].empty?
                record['instances'].select do |instance|
                    if instance['instance_type'] == "digital_object"
                        @linked_digital_objects << {resource_uri => instance['ref']}
                    else
                        @linked_top_containers << {resource_uri => instance.dig('sub_container', 'top_container', 'ref') || instance['ref']}
                    end
                end unless record['instances'].empty?
            end
        end

        @linked_aos_grouped = group_array_of_hashes(@linked_aos)
        @linked_agents_grouped = group_array_of_hashes(@linked_agents)
        @linked_instances_grouped = group_array_of_hashes(@linked_instances)
        @linked_top_containers_grouped = group_array_of_hashes(@linked_top_containers)
        @linked_digital_objects_grouped = group_array_of_hashes(@linked_digital_objects)

        # puts @linked_aos_grouped
        # puts @linked_agents_grouped
        # puts @linked_instances_grouped
        # puts @linked_top_containers_grouped
        # puts @linked_digital_objects_grouped
        #puts @linked_aos_grouped
        @report << @linked_aos_grouped.map do |group| 
                count_of_links(group)
            end
        @report << @linked_agents_grouped.map do |group| 
            count_of_links(group)
        end
        grouped_report = group_array_of_hashes(@report)
        grouped_report.map do |hash|
            row = [hash.map {|key,array| "#{key},#{array.map {|value| value}.join(',')}"}]
            puts row
            
        end

        #puts "count linked_aos links: #{count_of_links(@linked_aos_grouped)}"
        # puts "count linked_agents links: #{count_of_links(@linked_agents_grouped)}"
        # puts "count total instances links: #{count_of_links(@linked_instances_grouped)}"  
        # puts "count top_containers links: #{count_of_links(@linked_top_containers_grouped)}"   
        # puts "count digital_objects links: #{count_of_links(@linked_digital_objects_grouped)}"
    end
# end

puts Time.now
