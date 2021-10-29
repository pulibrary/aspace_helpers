require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

# #declare input file with uri and restriction value
csv = CSV.parse(File.read("input_add_barcode.csv"), :headers => true)
log = "log_add_barcode.txt"

csv.each do |row|
  #puts row['ao_uri']
  uri = row['container_uri']
  container = @client.get(uri).parsed
    ils_holding_id = container['ils_holding_id']
    container['barcode'] = ils_holding_id
  post = @client.post(uri, container.to_json)
  response = post.body
  File.write(log, response, mode: 'a')
  puts response
end
