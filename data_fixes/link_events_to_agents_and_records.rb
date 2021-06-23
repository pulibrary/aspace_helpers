require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'

aspace_staging_login()


#read in record and linked_record uri's from CSV
#fix gsub error by checking that each value is in one set of double quotes
csv = CSV.parse(File.read("data_fixes/event_missing_both_agent_and_resource.csv"), :headers => true)

csv.each do |row|
  record = @client.get(row['event_uri']).parsed
  record['linked_agents'] = [{'role' => 'authorizer', 'ref' => row['agent_uri']}]
  record['linked_records'] = [{'role' => 'source', 'ref' => row['resource_uri']}]
  post = @client.post(row['event_uri'], record.to_json)
  puts post.body
end
