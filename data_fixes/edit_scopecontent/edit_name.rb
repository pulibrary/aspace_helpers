require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

match_string = ENV['MATCH_STRING']
replace_string = ENV['REPLACE_STRING']
resources = get_all_records_for_repo_endpoint(5, "resources")
resources.each do |resource|
  processinfo_all = resource['notes'].select { |note| note["type"] == "processinfo" }
  unless processinfo_all[0].nil?
    #FIX THIS: MULTIPLE PROCESSING NOTES ARE POSSIBLE
    processinfo_text = processinfo_all[0]['subnotes'][0]['content']
    processinfo_all[0]['subnotes'][0]['content'] =
      if processinfo_text.match(match_string)
        processinfo_text.gsub!(match_string, replace_string)
        uri = resource['uri']
        post = @client.post(uri, resource.to_json)
        puts post.body
      end
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
