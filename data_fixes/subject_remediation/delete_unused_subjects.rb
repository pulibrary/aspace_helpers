require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

puts Time.now
@client = aspace_login

csv = CSV.parse(File.read("subjects_to_delete.csv"), :headers => true)
log = "remove_unused_subjects.txt"

csv.each do |row|
  uri = row['uri']
  delete = @client.delete(uri)
  response = delete.body
  puts response
  File.write(log, response, mode: 'a')
end
puts Time.now
