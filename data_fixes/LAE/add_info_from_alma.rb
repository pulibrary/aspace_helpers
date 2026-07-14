require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("simple_imports.csv"), :headers => true)
log = "simple_imports_20230922.txt"

csv.each do |row|
  #puts row['ao_uri']
  uri = row['uri']
  barcode = row['barcode']
  container = @client.get(uri).parsed
  container['barcode'] = barcode
  post = @client.post(uri, container.to_json)
  response = post.body
  File.write(log, response, mode: 'a')
  puts response
end
