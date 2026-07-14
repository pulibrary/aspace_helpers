require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

match_string = "This collection is stored offsite at the ReCAP facility."
replace_string = "This collection is stored offsite at the ReCAP facility. Please allow 1-3 days for delivery."
resources = get_all_records_for_repo_endpoint(8, "resources")
resources.each do |resource|
  physloc_all = resource['notes'].select { |note| note["type"] == "physloc" }
  physloc_all.each do |physloc|
    next unless physloc['subnotes'][0]['content'].match(match_string)

    physloc['subnotes'][0]['content'] = replace_string
    uri = resource['uri']
    post = @client.post(uri, resource.to_json)
    puts post.body
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
