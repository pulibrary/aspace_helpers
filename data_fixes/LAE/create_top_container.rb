require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login

puts "Process started: #{Time.now}"
#create containers from CSV
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/Religion in Cuba microfilm reels.csv"), :headers => true)
csv.each do |row|
record = 
  {
    "jsonmodel_type": "top_container",
    "indicator": "#{row['Call Number']} #{row['Volume']}",
    "type": "item",
    "barcode": "#{row['Barcode']}"
  }

  post = @client.post('/repositories/8/top_containers', record)
  puts post.body
end

