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
  altformavail_all = resource['notes'].select { |note| note["type"] == "altformavail" }
  altformavail_all.each do |altformavail|
    altformavail['subnotes'][0]['content'] = row['note']
    end
  post = @client.post(row['uri'], resource)
  response = post.body
  puts response
  end

end_time = "Process ended: #{Time.now}"
puts end_time
