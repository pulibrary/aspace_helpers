require 'archivesspace/client'
require_relative 'helper_methods.rb'

start_time = "Process started: #{Time.now}"
puts start_time

client = aspace_login(@production)
resources = get_all_resource_records_for_institution

output_file = "userestrict.csv"

CSV.open(output_file, "a",
         :write_headers => true,
         :headers => ["uri", "eadid", "title", "restriction_note"]) do |row|

  resources.each do |resource|
    uri = resource['uri']
    eadid = resource['ead_id']
    title = resource['title']
    notes = resource.dig('notes')
    restrictions_hash = notes.select { |hash| hash['type'] == "userestrict"}
    restriction_note =
          unless
            restrictions_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
            #replace linebreaks with single space
            restrictions_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
          end #unless
    puts "#{uri}, #{eadid}, #{title}, #{restriction_note}"
    row << [uri, eadid, title, restriction_note]
        rescue Exception => msg
          error = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
          puts error
  end
end
end_time = "Process started: #{Time.now}"
puts end_time
