require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

filename = 'test.csv'
#repos_all = (7..12).to_a
repos_all = [11]
aos = []

CSV.open(filename, "wb",
  :write_headers => true,
  :headers => ["self_uri", "self_restriction_type", "self_restriction_note", "parent_level", "parent_uri", "parent_restriction_type", "parent_restriction_note", "resource_level", "resource_uri", "resource_restriction_type", "resource_restriction_note"]) do |row|
  repos_all.each do |repo|
    aos << get_all_records_for_repo_endpoint(repo, 'archival_objects', ['parent', 'resource'])
    puts "Gathering records ended at #{Time.now}"
    aos = aos.flatten!
    aos.each do |ao|
      #get resource properties
      unless ao.dig('resource').nil?
        resource_level = ao['resource']['_resolved']['level']
        resource_uri = ao['resource']['ref']

        notes = ao.dig('resource', '_resolved', 'notes')
        restrictions_hash = notes.select { |hash| hash['type'] == "accessrestrict"}
        #puts restrictions_hash
        #puts restrictions_hash.class
        resource_restriction_type = restrictions_hash.dig(0, 'rights_restriction', 'local_access_restriction_type', 0)
        resource_restriction_note =
              unless
                restrictions_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
                restrictions_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
              end #unless
      end #unless
      #get parent properties
      unless ao.dig('parent').nil?
        parent_level = ao['parent']['_resolved']['level']
        parent_uri = ao['parent']['ref']
        notes = ao.dig('parent', '_resolved', 'notes')
        restrictions_hash = notes.select { |hash| hash['type'] == "accessrestrict"}
        parent_restriction_type = restrictions_hash.dig(0, 'rights_restriction', 'local_access_restriction_type', 0)
        parent_restriction_note =
              unless
                restrictions_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
                restrictions_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
              end #unless
      end #unless
      #get self properties
      self_uri = ao['uri']
      notes = ao.dig('notes')
      restrictions_hash = notes.select { |hash| hash['type'] == "accessrestrict"}
      self_restriction_type = restrictions_hash.dig(0, 'rights_restriction', 'local_access_restriction_type', 0)
      self_restriction_note =
            unless
              restrictions_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
              restrictions_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
            end #unless

      puts "#{self_uri}:#{unless self_restriction_type.nil?
        self_restriction_type
      end}:#{unless self_restriction_note.nil?
        self_restriction_note
      end}:#{parent_level}:#{parent_uri}:#{unless parent_restriction_type.nil?
        parent_restriction_type
      end}:#{unless parent_restriction_note.nil?
        parent_restriction_note
      end}:#{resource_level}:#{resource_uri}:#{unless resource_restriction_type.nil?
        resource_restriction_type
      end}:#{unless resource_restriction_note.nil?
        resource_restriction_note
      end}"
      #write to csv
      row << [self_uri, unless self_restriction_type.nil?
        self_restriction_type
      end, unless self_restriction_note.nil?
        self_restriction_note
      end, parent_level, parent_uri, unless parent_restriction_type.nil?
        parent_restriction_type
      end, unless parent_restriction_note.nil?
        parent_restriction_note
      end, resource_level, resource_uri, unless resource_restriction_type.nil?
        resource_restriction_type
      end, unless resource_restriction_note.nil?
        resource_restriction_note
      end]

    end #end aos.each
puts "Processing gathered records for repo #{repo} ended at #{Time.now}"
# rescue Exception => msg
# puts "Processing gathered records ended at #{Time.now} with error '#{msg.class}: #{msg.message}'"
end #repos.each
end #CSV.open
