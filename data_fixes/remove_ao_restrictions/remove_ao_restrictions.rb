require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login()

#first, get all aos out (write to csv?)
#/repositories/:repo_id/archival_objects

#second, iterate over all aos and get their ancestors out, if any
#third, get restriction for each ancestor
#then do comparison locally
#then change restrictions as appropriate

start_time = "Process started: #{Time.now}"
puts start_time

#ao = get_single_archival_object_by_id(3, 521207)

filename = 'get_aos.csv'
repos_all = (3..12).to_a
#repos_all = [11]
aos = []

CSV.open(filename, "wb",
  :write_headers => true,
  :headers => ["self_uri", "self_restriction", "self_restriction_note", "ancestor_level", "ancestor_uri"]) do |row|
  repos_all.each do |repo|
    aos << get_all_records_for_repo_endpoint(repo, 'archival_objects')
    puts "Gathering records ended at #{Time.now}"
    aos = aos.flatten!
    aos.each do |ao|
    ao.dig('ancestors').each do |ancestor|
      self_uri = ao['ref_id']
      ancestor_level = ancestor['level']
      ancestor_uri = ancestor['ref']
      restriction_notes = ao.dig('notes').each do |note|
        if note['type'] == "accessrestrict"
          then
          self_restriction = note.dig('rights_restriction', 'local_access_restriction_type')[0]
          self_restriction_note =
            unless
              note.dig('subnotes', 0, 'jsonmodel_type') != "note_text"
              note.dig('subnotes', 0, 'content')
            end

        puts "#{self_uri}: #{self_restriction}: #{self_restriction_note}: #{ancestor_level}: #{ancestor_uri}"

        row << [self_uri, self_restriction, self_restriction_note, ancestor_level, ancestor_uri]
        rescue Exception => msg
        puts "Processing gathered interrupted at #{Time.now} with error '#{msg.class}: #{msg.message}''"
        end #if
      end #end each
    end #end each
  end #end aos.each
end #end repos_all.each do
end #CSV.open


puts "Process ended: #{Time.now}"
