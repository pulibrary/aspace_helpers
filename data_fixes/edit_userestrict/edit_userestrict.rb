require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

accessrestrict_note = "test"
repos_all = (9..9).to_a

#iterate over all repositories
repos_all.each do |repo|
#iterate over all resources within repositories
resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    uri = resource['uri']
    #filter out all accessrestrict notes
    userestrict_all = resource['notes'].select { |note| note["type"] == "userestrict" }
    #iterate over all access notes
    userestrict_all.each do |userestrict|
        if userestrict.empty?
            record['notes'].append(
              {
                "jsonmodel_type"=>"note_multipart",
              "type"=>"userestrict",
              "subnotes"=>[
                {
                  "jsonmodel_type"=>"note_text",
                  "content"=>userestrict_note,
                  "publish"=>true
                }
              ],
              "publish"=>true
              }
            )
        else
            userestrict['subnotes'][0]['content'] = userestrict_note
        end
    end
    #write a revision statement to the record at the same time
    add_resource_revision_statement(resource, "Updated use restriction")
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
