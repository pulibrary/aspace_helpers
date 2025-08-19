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

    #unless record.dig('agent_record_identifiers').blank?
    #     record_id = @record['agent_record_identifiers'][0]['record_identifier'] ||= ''
        #source = record['agent_record_identifiers'][0]['source'] ||= ''
    #     authority_id = record_id.gsub(/\D+/, '')
    #     puts "#{uri}^#{record_id ||= ''}^#{authority_id ||= ''}^#{source ||= ''}"
    #end
    names = record['names']
    names[0]['authority_id'] = row['authority_id'] unless row['authority_id'].blank?
    names[0]['source'] = row['source'] unless row['source'].blank?
    names[0]['rules'] = row['rules'] unless row['rules'].blank?
    add_maintenance_history(record, "restore authority id, source, or rules to the names subrecord")
    #puts "#{uri}^#{date.dig('date_type_structured') unless date.nil?}^#{date.dig('date_certainty') unless date.nil?}^#{date.dig('structured_date_single','date_expression') unless date.nil?}^#{date.dig('structured_date_single','date_role') unless date.nil?}^#{date.dig('structured_date_single','date_standardized') unless date.nil?}^#{date.dig('structured_date_range','begin_date_expression') unless date.nil?}^#{date.dig('structured_date_range','begin_date_standardized') unless date.nil?}^#{date.dig('structured_date_range','end_date_expression') unless date.nil?}^#{date.dig('structured_date_range','end_date_standardized') unless date.nil?}"

    post = @client.post(uri, record)
    puts post.body

end

puts Time.now
