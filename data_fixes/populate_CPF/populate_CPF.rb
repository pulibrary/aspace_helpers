require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

agent_types = ['people']

@agent_records = []

#for each agent type, get agent records
agent_types.each do |agent_type|
  agent_ids = get_all_agents_by_type(agent_type)
  # puts agent_ids.class
  # puts agent_ids.count
  # puts agent_ids[5]
  agent_ids.each do |agent_id|
    @agent_records << get_agent_by_id(agent_type, agent_id)
  end
end
# puts @agent_records.class
# puts @agent_records.count
# puts @agent_records[0]
@agent_records = @agent_records.flatten!
#update agent record
@agent_records.each do |agent_record|
  #puts agent_record.class
  #prepare the data to post
  migration_event =
    {
      'event_date'=>'2020-01-01 00:00:00 UTC',
      'agent'=>'system',
      'descriptive_note'=>'Migrated records from a spreadsheet created from native EAC-CPF via OpenRefine.',
      'maintenance_event_type'=>'updated',
      'maintenance_agent_type'=>'machine'
    }

  maintenance_event =
    {
      'event_date'=>'2023-04-08 00:00:00 UTC',
      'agent'=>'system',
      'descriptive_note'=>'Upgraded records to re-populate the required CPF and ASpace fields that were lost during data import via OpenRefine.',
      'maintenance_event_type'=>'updated',
      'maintenance_agent_type'=>'machine'
    }

  #we can mostly count on records having a title, and we can boilerplate the source
  next if agent_record['title'].nil?

    identifier =
      if agent_record['names'][0]['authority_id'].nil?
        agent_record['title'].gsub(/\P{L}/, '').upcase
      else
        agent_record['names'][0]['authority_id'] + agent_record['names'][0]['authority_id'].gsub(/\D/, '')
      end
    identifier_source =
      if agent_record['names'][0]['source'].nil?
        "local"
      else
        agent_record['names'][0]['source']
      end
    control =
      {
        "maintenance_agency"=>"NjP",
        "agency_name"=>"Princeton University Library",
        "maintenance_status"=>"upgraded"
      }
    agent_record_identifier =
      {
        'record_identifier'=>identifier,
        'source'=>identifier_source,
        'primary_identifier'=>true
      }
      #populate the fields
      #add this if there is no maintenance event recorded
      if agent_record['agent_maintenance_histories'].empty?
        agent_record['agent_maintenance_histories'] << migration_event
      end
      #add this to describe the current maintenance action
      if agent_record['agent_record_identifiers'].empty? ||
         agent_record['agent_identifiers'].empty? ||
         agent_record['agent_record_controls'].empty?

          agent_record['agent_maintenance_histories'] << maintenance_event
      end
    #add identifiers
    if agent_record['agent_record_controls'].empty?
      agent_record['agent_record_controls'] << control
    end
    if agent_record['agent_record_identifiers'].empty?
      agent_record['agent_record_identifiers'] << agent_record_identifier
    end
    if agent_record['agent_identifiers'].empty?
      agent_record['agent_identifiers'] << {'entity_identifier'=>identifier}
    end
    unless agent_record['names'][0]['authority_id'].nil?
      agent_record['display_name']['source'] = identifier_source
    end
  #puts agent_record
  #post agent_record
  uri = agent_record['uri']
  post = @client.post(uri, agent_record.to_json)
  puts post.body
end
end_time = "Process ended: #{Time.now}"
puts end_time
