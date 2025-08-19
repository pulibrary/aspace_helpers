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

    unless record.dig('agent_record_identifiers').blank?
        record_id = @record['agent_record_identifiers'][0]['record_identifier'] ||= ''
        source = record['agent_record_identifiers'][0]['source'] ||= ''
        authority_id = record_id.gsub(/\D+/, '')
        puts "#{uri}^#{record_id ||= ''}^#{authority_id ||= ''}^#{source ||= ''}"
    end

end

puts Time.now
