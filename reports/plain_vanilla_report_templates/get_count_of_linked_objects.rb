require 'archivesspace/client'
require 'active_support/all'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login
puts Time.now

output_file = "linked_records.csv"
repositories = (3..12).to_a
record_types = ["resources", "archival_objects"]
record_types_to_prefetch = []

def count_of_links(array)
    array.map {|k, v| {k=>v.compact_blank.count}}.flatten
end

def group_array_of_hashes(array)
    array.flatten.group_by(&:keys).map do |key, values|
        {key.join => values.map { |value_hash| value_hash.values.join}}
    end
end

CSV.open(output_file, "w",
    :write_headers => true,
    :headers => ["uri", "eadid or cid", "linked_aos", "linked_agents", "linked_subjects", "linked_accessions", "linked_deaccessions", "linked_instances", "linked_containers", "linked_digital_objects", "linked_events"]) do |row|
    repositories.each do |repo|
        @linked_aos = []
        @linked_agents = []
        @linked_subjects = []
        @linked_accessions = []
        @linked_deaccessions = []
        @linked_instances = []
        @linked_top_containers = []
        @linked_digital_objects = []
        @linked_events = []
        linked_object_arrays =
          [
            @linked_aos,
            @linked_agents,
            @linked_subjects,
            @linked_accessions,
            @linked_deaccessions,
            @linked_instances,
            @linked_top_containers,
            @linked_digital_objects,
            @linked_events
          ]
        @eadids = {}
        record_types.each do |record_type|
            #get all record id's for the repository
            all_record_ids = @client.get("/repositories/#{repo}/#{record_type}",
                query: {
                  all_ids: true
                }).parsed

            #get all resolved records from id's and select those with linked agents
            all_records = get_resolved_objects_from_ids(repo, all_record_ids, record_type, record_types_to_prefetch)
            #store data points in variables
            all_records.map do |record|
                resource_uri =
                  if record['resource'].nil?
                      record['uri']
                  else
                      record['resource']['ref']
                  end
                @eadids.store(resource_uri.to_s, record['id_0']) if record['resource'].nil?
                @linked_aos <<
                  if record['jsonmodel_type'] == "archival_object"
                      {resource_uri => record['uri']}
                  end
                @linked_agents <<
                  if record['linked_agents'].empty?
                      {resource_uri => nil}
                  else
                      record['linked_agents'].map do |agent|
                     {resource_uri => agent['ref']}
                      end
                  end
                @linked_subjects <<
                  if record['subjects'].empty?
                      {resource_uri => nil}
                  else
                      record['subjects'].map do |subject|
                     {resource_uri => subject['ref']}
                      end
                  end
                @linked_accessions <<
                  if record['related_accessions'].nil?
                      {resource_uri => nil}
                  else
                      record['related_accessions'].map do |accession|
                     {resource_uri => accession['ref']}
                      end
                  end
                @linked_deaccessions <<
                  if record['deaccessions'].nil?
                      {resource_uri => nil}
                  else
                      record['deaccessions'].map do |deaccession|
                     {resource_uri => deaccession['ref']}
                      end
                  end
                @linked_instances <<
                  if record['instances'].empty?
                      {resource_uri => nil}
                  else
                      record['instances'].map do |instance|
                      {resource_uri => instance.dig('sub_container', 'top_container', 'ref') || instance['ref'] || instance['digital_object']['ref']}
                      end
                  end
                unless record['instances'].empty?
                  instance_types = record['instances'].select do |instance|
                      if instance['instance_type'] == "digital_object"
                          @linked_digital_objects << {resource_uri => instance['digital_object']['ref']}
                          @linked_top_containers << {resource_uri => nil}
                      end
                      if instance['instance_type'] == "mixed_materials"
                          @linked_top_containers << {resource_uri => instance.dig('sub_container', 'top_container', 'ref')}
                          @linked_digital_objects << {resource_uri => nil}
                      end
                  end
                end
                @linked_events <<
                  if record['linked_events'].empty?
                      {resource_uri => nil}
                  else
                      record['linked_events'].map do |event|
                     {resource_uri => event['ref']}
                      end
                  end
            end
        end

        #add all counts by linked object type to the report array
        report = linked_object_arrays.map do |array|
            group_array_of_hashes(array).map do |group|
                count_of_links(group)
            end
        end
        #group the report again by resource uri
        grouped_report = group_array_of_hashes(report)
        #construct csv row from the grouped report
        #counts are in order of the linked_objects_array
        grouped_report.map do |hash|
            row_to_terminal = hash.map {|key, array| "#{key},#{@eadids[key]},#{array.map {|value| value}.join(',')}"}
            puts row_to_terminal
            hash.map do |key, array|
                row << ([key, @eadids[key]] + array.to_csv.split(",").map(&:strip))
            end
        end
    end
end

puts Time.now
