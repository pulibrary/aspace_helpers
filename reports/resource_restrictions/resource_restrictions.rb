require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'

aspace_login()
start_time = "Process started: #{Time.now}"
puts start_time

filename = "resource_restrictions.csv"
records = get_all_resource_records_for_institution
CSV.open(filename, "wb",
  :write_headers => true,
  :headers => ["eadid", "uri", "restriction_type", "restriction_note"]) do |row|

  records.each do |record|
    notes = record.dig('notes')
      restrictions_hash = notes.select { |hash| hash['type'] == "accessrestrict"}
      resource_restriction_type = restrictions_hash.dig(0, 'rights_restriction', 'local_access_restriction_type', 0)
      resource_restriction_note =
            unless
              restrictions_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
              restrictions_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
            end #unless

  row << [record['ead_id'],
    record['uri'],
    unless resource_restriction_type.nil?
      resource_restriction_type
    end,
    unless resource_restriction_note.nil?
      resource_restriction_note
    end]
  puts "#{record['ead_id']}:#{record['uri']}:#{resource_restriction_type || ""}: #{resource_restriction_note || ""}"
  end
end #row

end_time = "Process started: #{Time.now}"
puts end_time
