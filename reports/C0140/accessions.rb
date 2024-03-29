require 'archivesspace/client'
require 'active_support/all'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login
puts Time.now

output_file = "C0140_accessions.csv"
record_uri = "repositories/5/resources/3950"

CSV.open(output_file, "w",
    :write_headers => true,
    :headers => ["uri", "title", "identifier_1", "identifier_2", "identifier_3", "identifier_4", "description", "disposition", "linked_to_resource", "provenance"]) do |row|
        record = @client.get(record_uri, query: {
                               #the record has no deaccessions, so only grabbing accessions here
                               resolve: ["related_accessions"]
                             }).parsed
        record['related_accessions'].map do |accession|
        row << [
          accession['ref'],
          accession['_resolved']['title'],
          accession['_resolved']['id_0'],
          accession['_resolved']['id_1'],
          accession['_resolved']['id_2'],
          accession['_resolved']['id_3'],
          accession['_resolved']['content_description'],
          accession['_resolved']['disposition'],
          accession['_resolved']['related_resources'].map {|resource| resource['ref']}.join(';'),
          accession['_resolved']['provenance']
        ]
    end
end
