require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'
require 'csv'
require 'json'

@client = aspace_login

puts Time.now

    ['people', 'corporate_entities', 'families'].each do |agent_type|
        ids = []
        ids << @client.get("/agents/#{agent_type}", {
                             query: {
                               all_ids: true
                             }
                           }).parsed
        ids = ids.flatten

        ids.each do |id|
            record = @client.get("/agents/#{agent_type}/#{id}").parsed
            next if record.nil?

            next unless record.dig('names', 0, 'source').blank? || record.dig('names', 0, 'source') == 'local'

            uri = record['uri']
            source = record['names'][0]['source'] ||= ''
            rules = record['names'][0]['rules'] ||= ''
            authority = record['names'][0]['authority_id'] ||= ''
            unless record['agent_identifiers'].blank?
                entity_id = record.dig('agent_identifiers', 0, 'entity_identifier')
            end
            title = record['title']
            puts "#{uri}^#{title ||= ''}^#{source ||= ''}^#{rules ||= ''}^#{authority ||= ''}^#{entity_id ||= ''}"
        end
    end

puts Time.now
