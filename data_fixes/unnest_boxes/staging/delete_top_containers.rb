require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("delete_top_containers.csv"), :headers => true)

csv.each do |row|
  #puts row['ao_uri']
  uri = row['tc_uri']
  post = @client.delete(uri)
  response = post.body
  puts response
end
