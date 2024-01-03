require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

phrase = /RBSC's/
input_file = 

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

resource = 
uri = resource['uri']
#filter out all accessrestrict notes
accessrestrict_all = resource['notes'].select { |note| note["type"] == "accessrestrict" }
#replace the offending string if found
accessrestrict_all.each do |accessrestrict|
    note_text = accessrestrict['subnotes'][0]['content'][0.74]
    next if accessrestrict.empty?      
    elsif note_text.match(phrase)
        note_text.content.gsub(phrase,"the RBSC")
    else ()
    end
end
    #write a revision statement to the record at the same time
    add_resource_revision_statement(resource, "Updated accessrestrict")
    post = @client.post(uri, resource.to_json)
    puts post.body
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
