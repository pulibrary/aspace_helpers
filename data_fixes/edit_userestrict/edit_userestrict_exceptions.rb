require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

#define input variables
log = "log_userestrict.txt"
input_file = "input.csv"
csv = CSV.parse(File.read(input_file), :headers => true)
userestrict_note = "test"
csv.each do |row|
    uri = row['uri']
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
    add_resource_revision_statement(uri, "Updated use restriction.")
    post = @client.post(uri, resource.to_json)
    puts post.body
    File.write(log, post.body, mode: 'a')
    end
    rescue Exception => msg
    error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
    puts error
    end

end

end_time = "Process ended: #{Time.now}"
puts end_time
