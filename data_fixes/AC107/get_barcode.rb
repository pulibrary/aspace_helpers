require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("log_create_top_containers.csv"), :headers => true)

csv.each do |row|
  uri = row['uri']
  top_container = @client.get(uri).parsed
  puts "#{top_container['uri']}, #{top_container['barcode']}"
end
