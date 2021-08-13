require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../helper_methods.rb'

aspace_login()


#read in record and linked_record uri's from CSV
#fix gsub error by checking that each value is in one set of double quotes
csv = CSV.parse(File.read("orphaned_events_links.csv"), :headers => true)

csv.each do |row|
  record = @client.get(row['uri']).parsed
  record['linked_records'] = [{'role' => 'source', 'ref' => row['linked_uri']}]
  post = @client.post(row['uri'], record.to_json)
  puts post.body
end
