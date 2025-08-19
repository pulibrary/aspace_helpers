require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'
require 'csv'
require 'json'

@client = aspace_login

puts Time.now

csv = CSV.parse(File.read("restore_authorized.csv"), :headers => true)

csv.each do |row|
    uri = row['uri']
    record = @client.get(uri).parsed
    next if record.nil?

names = record['names']
    names[0]['authority_id'] = row['authority_id'] unless row['authority_id'].blank?
    names[0]['source'] = row['source'] unless row['source'].blank?
    names[0]['rules'] = row['rules'] unless row['rules'].blank?
    add_maintenance_history(record, "restore authority id, source, or rules to the names subrecord")

    post = @client.post(uri, record)
    puts post.body
end

puts Time.now
