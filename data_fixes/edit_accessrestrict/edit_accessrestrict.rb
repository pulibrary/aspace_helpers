require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

accessrestrict_type = "test"
accessrestrict_note = "test"

repos_all = (9..9).to_a

#iterate over all repositories
repos_all.each do |repo|
#iterate over all resources within repositories
resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    uri = resource['uri']
    #filter out all accessrestrict notes
    accessrestrict_all = resource['notes'].select { |note| note["type"] == "accessrestrict" }
    #iterate over all access notes
    accessrestrict_all.each do |accessrestrict|
        if accessrestrict.empty?
            record['notes'].append(
              {
                "jsonmodel_type"=>"note_multipart",
              "type"=>"accessrestrict",
              "rights_restriction"=>{
                "local_access_restriction_type"=>accessrestrict_type
              },
              "subnotes"=>[
                {
                  "jsonmodel_type"=>"note_text",
                  "content"=>accessrestrict_note,
                  "publish"=>true
                }
              ],
              "publish"=>true
              }
            )
        else
            accessrestrict['rights_restriction']['local_access_restriction_type'] = accessrestrict_type
            accessrestrict['subnotes'][0]['content'] = accessrestrict_note
        end
    end
    #write a revision statement to the record at the same time
    add_resource_revision_statement(resource, "Updated accessrestrict")
    # post = @client.post(uri, resource.to_json)
    # puts post.body
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
