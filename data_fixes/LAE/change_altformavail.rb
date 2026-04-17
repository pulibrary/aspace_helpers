require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/altformavail.csv"), :headers => true)
csv.each do |row|
  resource = @client.get(row['uri']).parsed
  resource['notes'].delete_if { |note| note["type"] == "altformavail" }
  resource['notes'].append(
    {"jsonmodel_type" => "note_multipart",
    "type" => "altformavail",
    "subnotes" => [{
      "jsonmodel_type" => "note_text",
      "content" => "<p>Images of this collection may be viewed online in the <extref href=\"#{row['ark']}\">PUL catalog</extref> (scroll down for the image viewer).</p>#{row['note']}",
      "publish" => true
    }],
      "publish" => true}
  )
    post = @client.post(row['uri'], resource)
    response = post.body
    puts response
end
end_time = "Process ended: #{Time.now}"
puts end_time
