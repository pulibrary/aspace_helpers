require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

resources = get_all_records_of_type_in_repo("resources", 8)
resources.each do |resource|
  altformavail_all = resource['notes'].select { |note| note["type"] == "altformavail" }
  altformavail_all.each do |altformavail|
    puts "#{resource['ead_id']}^#{resource['uri']}^#{altformavail['subnotes'][0]['content'].gsub! /\n/, ' '}"
    end
  end

end_time = "Process ended: #{Time.now}"
puts end_time
