require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

match_string = "<p>
This collection has been fully digitized and the digital images are available here: <extref xlink:href=\"https://dpul.princeton.edu/lae-dig-microfilm\">Latin American Ephemera: Digitized Microfilm Sets</extref>.
</p>"
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/altformavail.csv"), :headers => true)
csv.each do |row|
  replace_string = "<p>Images of this collection may be viewed online in the <extref href=\"#{row['ark']}\">PUL catalog</extref> (scroll down for the image viewer) or on the <extref xlink:href=\"https://dpul.princeton.edu/lae-dig-microfilm\">Latin American Ephemera: Digitized Microfilm Sets</extref> site.</p>"
  resource = @client.get(row['uri']).parsed
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
