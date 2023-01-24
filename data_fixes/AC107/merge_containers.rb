require 'archivesspace/client'
require 'json'
require 'active_support/all'
require 'net/sftp'
require_relative '../../helper_methods.rb'

@client = aspace_login

csv = CSV.parse(File.read("AC107_Merge_Duplicate_Containers.csv"), :headers => true)
  csv.each do |row|
    target = row['target'].to_s
    victim = row['victim'].to_s

    update=@client.post('/merge_requests/top_container?repo_id=4', {
      'uri': 'merge_requests/top_container',
      'target': {'ref':target},
      'victims': [{'ref':victim}]
    }.to_json
    )
    puts update.body
end
