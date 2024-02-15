require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_login
puts Time.now

output_file = "linked_records.csv"
record_types_to_count = ["linked_agents", "subjects", "linked_events", "related_accessions", "deaccessions", "instances"]
resource = "/repositories/5/resources/3950"
all_records = []
@linked_agents_counts = 0
@subjects_counts = 0
@linked_events_counts = 0
@related_accessions_counts = 0
@deaccessions_counts = 0
@instances_counts = 0
@instance_digital_object_counts = 0
@instance_top_container_counts = 0

#get objects and counts
uris = @client.get("#{resource}/ordered_records").parsed['uris']
uris.each do |uri|
    record = @client.get(uri['ref']).parsed
    all_records << record
    @linked_agents_counts += record['linked_agents'].count
    @subjects_counts += record['subjects'].count
    @linked_events_counts += record['linked_events'].count
    unless record['related_accessions'].nil?
      @related_accessions_counts +=
        record['related_accessions'].count
    end
    @deaccessions_counts += record['deaccessions'].count unless record['deaccessions'].nil?
    @instances_counts += record['instances'].count
    digital_object_count =
      record['instances'].select do |instance|
          instance['instance_type'] == "digital_object"
      end.count
    top_container_count =
      record['instances'].reject do |instance|
          instance['instance_type'] += "digital_object"
      end.count
    @instance_digital_object_counts += digital_object_count.to_i
    @instance_top_container_counts += top_container_count.to_i
end

puts "Total archival object links (= total linked aos): #{all_records.count.to_i - 1}"
puts "Total agent links: #{@linked_agents_counts}"
puts "Total subject links: #{@subjects_counts}"
puts "Total event links: #{@linked_events_counts}"
puts "Total accession links (=total linked accessions): #{@related_accessions_counts}"
puts "Total deaccessions links (=total linked deaccessions): #{@deaccessions_counts}"
puts "Total instance links: #{@instances_counts}"
puts "Total digital_object links: #{@instance_digital_object_counts}"
puts "Total top_container links: #{@instance_top_container_counts}"

puts Time.now
