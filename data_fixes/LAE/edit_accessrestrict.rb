require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

match_string = "This collection has been fully digitized and the digital images are available on the "
replace_string = "This collection has been fully digitized and the digital images are available here: "
resources = get_all_records_of_type_in_repo("resources", 8)
resources.each do |resource|
  accessrestrict_all = resource['notes'].select { |note| note["type"] == "accessrestrict" }
  accessrestrict_all.each do |accessrestrict|
    accessrestrict_text = accessrestrict['subnotes'][0]['content']
    accessrestrict['subnotes'][0]['content'] =
      if accessrestrict_text.match(match_string)
        accessrestrict_text.gsub!(match_string, replace_string)
        uri = resource['uri']
        post = @client.post(uri, resource)
        puts post.body
      end
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
