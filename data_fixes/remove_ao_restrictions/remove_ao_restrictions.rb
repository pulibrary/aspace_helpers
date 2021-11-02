require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

filename = 'get_aos.csv'
#repos_all = (3..12).to_a
repos_all = [11]
aos = []

CSV.open(filename, "wb",
  :write_headers => true,
  :headers => ["self_uri", "self_restriction", "self_restriction_note", "parent_level", "parent_uri", "parent_restriction", "parent_restriction_type", "resource_level", "resource_uri", "resource_restriction", "resource_restriction_note"]) do |row|
  repos_all.each do |repo|
    aos << get_all_records_for_repo_endpoint(repo, 'archival_objects', ['parent', 'resource'])
    puts "Gathering records ended at #{Time.now}"
    aos = aos.flatten!
    aos.each do |ao|
      #get resource properties
      unless ao.dig('resource').nil?
        resource_level = ao['resource']['_resolved']['level']
        resource_uri = ao['resource']['ref']
        resource_restriction = []
        resource_restriction_note = []
        restriction_notes = ao.dig('resource', '_resolved', 'notes').each do |note|
          if note['type'] == "accessrestrict"
            then
            resource_restriction << note.dig('rights_restriction', 'local_access_restriction_type', 0)
            resource_restriction_note <<
              unless
                note.dig('subnotes', 0, 'jsonmodel_type') != "note_text"
                note.dig('subnotes', 0, 'content')
              end #unless
          end #if
        end #end each note
      end #unless
      #get parent properties
      unless ao.dig('parent').nil?
        parent_level = ao['parent']['_resolved']['level']
        parent_uri = ao['parent']['ref']
        parent_restriction = []
        parent_restriction_note = []
        restriction_notes = ao.dig('parent', '_resolved', 'notes').each do |note|
          if note['type'] == "accessrestrict"
            then
            parent_restriction << note.dig('rights_restriction', 'local_access_restriction_type', 0)
            parent_restriction_note <<
              unless
                note.dig('subnotes', 0, 'jsonmodel_type') != "note_text"
                note.dig('subnotes', 0, 'content')
              end #unless
          end #if
        end #end each note
      end #unless
      #get self properties
      self_uri = ao['uri']
      self_restriction = []
      self_restriction_note = []
      restriction_notes = ao.dig('notes').each do |note|
        if note['type'] == "accessrestrict"
          then
          self_restriction << note.dig('rights_restriction', 'local_access_restriction_type', 0)
          self_restriction_note <<
            unless
              note.dig('subnotes', 0, 'jsonmodel_type') != "note_text"
              note.dig('subnotes', 0, 'content')
            end #unless
        end #if
      end #end each note
      puts "#{self_uri}:#{unless self_restriction.nil?
        self_restriction[0]
      end}:#{unless self_restriction_note.nil?
        self_restriction_note[0]
      end}:#{parent_level}:#{parent_uri}:#{unless parent_restriction.nil?
        parent_restriction[0]
      end}:#{unless parent_restriction_note.nil?
        parent_restriction_note[0]
      end}:#{resource_level}:#{resource_uri}:#{unless resource_restriction.nil?
        resource_restriction[0]
      end}:#{unless resource_restriction_note.nil?
        resource_restriction_note[0]
      end}"
      #write to csv
      row << [self_uri, unless self_restriction.nil?
        self_restriction[0]
      end, unless self_restriction_note.nil?
        self_restriction_note[0]
      end, parent_level, parent_uri, unless parent_restriction.nil?
        parent_restriction[0]
      end, unless parent_restriction_note.nil?
        parent_restriction_note[0]
      end, resource_level, resource_uri, unless resource_restriction.nil?
        resource_restriction[0]
      end, unless resource_restriction_note.nil?
        resource_restriction_note[0]
      end]

    end #end aos.each
puts "Processing gathered records ended at #{Time.now}""
rescue Exception => msg
puts "Processing gathered records ended at #{Time.now} with error '#{msg.class}: #{msg.message}'"
end #repos.each
end #CSV.open
