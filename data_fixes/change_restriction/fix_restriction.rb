require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

log = "log_aclu_restrictions_20220426.csv"
csv = CSV.parse(File.read("aclu_restrictions_20220426.csv"), :headers => true)

  csv.each do |row|
    record = @client.get(row['uri']).parsed
    accessrestrict = record['notes'].select { |note| note["type"] == "accessrestrict" }
    unless accessrestrict.empty?
      #change restriction type here. Takes an array.
      #accessrestrict[0]['rights_restriction']['local_access_restriction_type'] = ["Open"]
      accessrestrict[0]['rights_restriction']['local_access_restriction_type'] = [row['restriction_type']]
      #change restriction note here. Takes a string.
      accessrestrict[0]['subnotes'][0]['content'] = row['restriction_note']
      #change the end date here
      #accessrestrict[0]['rights_restriction']['end'] = row['end_date'] unless row['end_date'].empty?
    else
      record['notes'].append(
          {"type"=>"accessrestrict",
          "subnotes"=>[{"jsonmodel_type"=>"note_text",
            "content"=>row['restriction_note'],
            "publish"=>true}],
          "jsonmodel_type"=>"note_multipart",
          "rights_restriction"=>{"local_access_restriction_type"=>[row['restriction_type']]},
          "publish"=>true})
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
