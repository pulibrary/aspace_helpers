require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

resources = get_all_records_of_type_in_repo("resources", 8)
resources.each do |resource|
  accessrestrict_all = resource['notes'].select { |note| note["type"] == "accessrestrict" }
  accessrestrict_all.each do |accessrestrict|
    puts "#{resource['ead_id']}^#{resource['uri']}^#{accessrestrict['rights_restriction']['local_access_restriction_type'][0]}^#{accessrestrict['subnotes'][0]['content'].gsub! /\n/, ' '}"
    end
  end

end_time = "Process ended: #{Time.now}"
puts end_time
