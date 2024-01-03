require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

#we don't need to do this for software
#, 'corporate_entities', 'families'
agent_types = ['people']

@agent_records = []

#for each agent type, get agent records
agent_types.each do |agent_type|
  agent_ids = [
    146,
    787,
    1891,
    2392,
    4754,
    5155,
    5258,
    5284,
    5316,
    5349,
    5380,
    5417,
    5472,
    5576,
    5759,
    5900,
    6103,
    6127,
    6163,
    6291,
    7523,
    7588,
    7594,
    7760,
    7785,
    7935,
    8082,
    8371,
    8375,
    8391,
    8395,
    8399,
    8401,
    8409,
    8413,
    8415,
    8417,
    8421,
    8429,
    8431,
    8433,
    8439,
    8441,
    8443,
    8447,
    8449,
    8451,
    8459,
    8463,
    8465,
    8469,
    8475,
    8481,
    8485,
    8489,
    8491,
    8495
  ]
  # puts agent_ids.class
  # puts agent_ids.count
  # puts agent_ids[5]
  # puts "Last agent processed has index: "
  # puts agent_ids.find_index(8455)
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
  # migration_event =
  #   {
  #     'event_date'=>'2020-01-01 00:00:00 UTC',
  #     'agent'=>'system',
  #     'descriptive_note'=>'Migrated records from a spreadsheet created from native EAC-CPF via OpenRefine.',
  #     'maintenance_event_type'=>'updated',
  #     'maintenance_agent_type'=>'machine'
  #   }
  #
  # maintenance_event =
  #   {
  #     'event_date'=>'2023-04-26 00:00:00 UTC',
  #     'agent'=>'system',
  #     'descriptive_note'=>'Upgraded records to re-populate the required CPF and ASpace fields that were lost during data import via OpenRefine.',
  #     'maintenance_event_type'=>'updated',
  #     'maintenance_agent_type'=>'machine'
  #   }

  #we can mostly count on records having a title, and we can boilerplate the source
  next if agent_record['title'].nil?

    # name_identifier =
    #   if agent_record['names'][0]['authority_id'].nil?
    #     agent_record['title'].gsub(/\P{L}/, '').upcase
    #   else
    #     agent_record['title'].gsub(/\P{L}/, '').upcase + agent_record['names'][0]['authority_id'].gsub(/\D/, '')
    #   end
    # identifier_source =
    #   if agent_record['names'][0]['source'].nil?
    #     "local"
    #   else
    #     agent_record['names'][0]['source']
    #   end
    #
    # agent_record_identifier =
    #   {
    #     'record_identifier'=>name_identifier,
    #     'source'=>identifier_source,
    #     'primary_identifier'=>true
    #   }

    # control =
    #   {
    #     "maintenance_agency"=>"NjP",
    #     "agency_name"=>"Princeton University Library",
    #     "maintenance_status"=>"upgraded"
    #   }

    #populate the fields
    #add this if there is no maintenance event recorded
    # if agent_record['agent_maintenance_histories'].empty?
    #   agent_record['agent_maintenance_histories'] << migration_event
    # end
    #add this to describe the current maintenance action
    # if agent_record['agent_record_identifiers'].empty? ||
    #    agent_record['agent_identifiers'].empty? ||
    #    agent_record['agent_record_controls'].empty?
    #
    #     agent_record['agent_maintenance_histories'] << maintenance_event
    # end
    #add identifiers
    # if agent_record['agent_record_controls'].empty?
    #   agent_record['agent_record_controls'] << control
    # end
    # puts agent_record['agent_record_identifiers'][0]['record_identifier']
    # if agent_record['agent_record_identifiers'][0]['record_identifier'] =~ /\w\s?https?:\/\/viaf.org\//
    #   agent_record['agent_record_identifiers'][0]['record_identifier'] = name_identifier
    # end unless agent_record['agent_record_identifiers'].nil?
    # # puts agent_record['agent_identifiers'][0]['entity_identifier']
    # puts name_identifier
    uri = agent_record['uri']
    if agent_record['agent_identifiers'][1] && (agent_record['agent_identifiers'][0]['entity_identifier'] == agent_record['agent_identifiers'][1]['entity_identifier'])
        agent_record['agent_identifiers'][1] = nil
      end
  # unless agent_record['names'][0]['authority_id'].nil?
  #   agent_record['display_name']['source'] = identifier_source
  # end
  #puts agent_record
  #post agent_record
  # uri = agent_record['uri']
  post = @client.post(uri, agent_record.to_json)
  puts post.body
end
end_time = "Process ended: #{Time.now}"
puts end_time
