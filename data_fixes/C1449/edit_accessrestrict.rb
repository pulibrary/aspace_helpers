require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login

resource_uri = "/repositories/5/resources/3838"
resource = @client.get(resource_uri).parsed
phrase = /RBSC's/
input_file = "input.csv"
csv = CSV.parse(File.read(input_file), :headers => true)
log = "log_replace_text.txt"

start_time = "Process started: #{Time.now}"
puts start_time

csv.each do |row|
    uri = row['uri']
    record = @client.get(uri).parsed
    #filter out all accessrestrict notes
    accessrestrict_all = record['notes'].select { |note| note["type"] == "accessrestrict" }
    #replace the offending string if found
    accessrestrict_all.each do |accessrestrict|
        note_text = accessrestrict['subnotes'][0]['content']
        next if accessrestrict.empty?

        if note_text.match?(phrase)
            accessrestrict['subnotes'][0]['content'] = note_text.gsub(phrase, "the RBSC")
        end
    end
    post = @client.post(uri, record.to_json)
    puts post.body
    File.write(log, post.body, mode: 'a')
    rescue Exception => msg
    error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
    puts error
end

write a revision statement to the record at the same time
add_resource_revision_statement(resource, "Reworded accessrestrict without apostrophe to avoid known requesting issue.")
post = @client.post(resource_uri, resource.to_json)
puts post.body
File.write(log, post.body, mode: 'a')

end_time = "Process ended: #{Time.now}"
puts end_time
