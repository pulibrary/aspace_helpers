require 'archivesspace/client'
require 'active_support/all'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

puts "Process started: #{Time.now}"
#create digital objects from CSV
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/do.csv"), :headers => true)
csv.each do |row|
record =
  {
  "jsonmodel_type"=>"digital_object",
  "digital_object_id"=>row['identifier'],
  "title"=>row['title'],
  "publish"=>true,
  "restrictions"=>false,
  "file_versions"=>[{
  "file_uri"=>"https://figgy.princeton.edu/concern/scanned_resources/#{row['identifier']}/manifest",
  "publish"=>true,
  "created_by"=>"admin",
  "jsonmodel_type"=>"file_version",
  "is_representative"=>false,
  "identifier"=>row['ark']
    }]
  }
  post = @client.post('/repositories/8/digital_objects', record)
  puts "#{row['uri']}^#{post.body}"
end
