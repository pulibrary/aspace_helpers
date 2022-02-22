require 'archivesspace/client'
require 'json'
require 'csv'
require 'pony'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

log = "log_set_end_date.csv"
csv = CSV.parse(File.read("set_end_date.csv"), :headers => true)

#get ao's for one collection
#ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed

  csv.each do |row|
    record = @client.get(row['uri']).parsed
    #accessrestrict might need to be overwritten or created
    new_accessrestrict =
        {
        "jsonmodel_type"=>"note_multipart",
        "type"=>"accessrestrict",
        "rights_restriction"=>{"end"=>row['end_date'],
        "local_access_restriction_type"=>[row['restriction_type']]},
        "subnotes"=>[{"jsonmodel_type"=>"note_text",
        "content"=>row['restriction_note'],
        "publish"=>true}],
        "publish"=>true
        }
    accessrestrict = record['notes'].select { |note| note["type"] == "accessrestrict" }[0]
    if accessrestrict.nil? == false
      accessrestrict = accessrestrict.replace(new_accessrestrict)
    else
      if record['notes'].any?
        then record['notes'] << new_accessrestrict
      else record['notes'] = [new_accessrestrict]
      end
    end

    post = @client.post(row['uri'], record.to_json)
    #write to log
    File.write(log, post.body, mode: 'a')
    puts post.body
    rescue Exception => msg
    error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
    puts error
   end

puts "Process ended #{Time.now}."
