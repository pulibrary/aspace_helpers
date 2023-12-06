require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

#define input variables
log = "log_userestrict.txt"
input_file = "exceptions.csv"
csv = CSV.parse(File.read(input_file), :headers => true)
csv.each do |row|
    uri = row['uri']
    userestrict_note = row['note']
    resource = @client.get(uri).parsed
    #filter out all accessrestrict notes
    userestrict_all = resource['notes'].select { |note| note["type"] == "userestrict" }
    #iterate over all access notes
    userestrict_all.each do |userestrict|
        if userestrict.empty?
            resource['notes'].append(
              {
                "jsonmodel_type"=>"note_multipart",
              "type"=>"userestrict",
              "subnotes"=>[
                {
                  "jsonmodel_type"=>"note_text",
                "content"=>"<p>#{userestrict_note}</p>",
                "publish"=>true
                }
              ],
              "publish"=>true
              }
            )
        else
            userestrict['subnotes'][0]['content'] = "<p>#{userestrict_note}</p>"
        end
    #write a revision statement to the record at the same time
    add_resource_revision_statement(resource, "Updated use restriction with exception to default statement.")
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
