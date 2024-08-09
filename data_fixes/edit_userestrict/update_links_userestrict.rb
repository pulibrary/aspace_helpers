require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time
log = "log_userestrict.txt"

repos_all = (12..12).to_a

#iterate over all repositories
repos_all.each do |repo|
#iterate over all resources within repositories
resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    uri = resource['uri']
    #get all userestrict notes
    userestrict_all = resource['notes'].select { |note| note["type"] == "userestrict" }
    #iterate over all userestrict notes
    userestrict_all.each do |userestrict|
        if userestrict['subnotes'][0]['content'].include? "https://library.princeton.edu/special-collections/ask-us"
            userestrict['subnotes'][0]['content'] = userestrict['subnotes'][0]['content'].gsub("https://library.princeton.edu/special-collections/ask-us", "https://library.princeton.edu/services/special-collections/ask-special-collections")
        end
        if userestrict['subnotes'][0]['content'].include? "https://library.princeton.edu/special-collections/policies/copyright-credit-and-citation-guidelines"
            userestrict['subnotes'][0]['content'] = userestrict['subnotes'][0]['content'].gsub("https://library.princeton.edu/special-collections/policies/copyright-credit-and-citation-guidelines", "test")
        end
    end
    #write a revision statement to the record at the same time
    #add_resource_revision_statement(resource, "Updated links")
    post = @client.post(uri, resource.to_json)
    puts post.body
    File.write(log, post.body, mode: 'a')
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
