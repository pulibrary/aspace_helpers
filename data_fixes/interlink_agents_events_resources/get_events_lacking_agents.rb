require 'archivesspace/client'
require 'csv'
require_relative '../helper_methods.rb'

aspace_login()

#get all event records
events_all = get_all_event_records_for_institution()
#filter for orphaned records
selected_events =
  events_all.select {|event| event['linked_agents'].empty? == true}
#write selected fields to CSV
filename = "events_lacking_agents.csv"
CSV.open(filename, "wb",
         :write_headers=> true,
         :headers => ["uri", "created_by", "create_time", "event_type", "outcome_note"]) do |row|
      selected_events.each do |event|
        uri = event['uri']
        creator = event['created_by']
        date = event['create_time']
        action = event['event_type']
        note = event['outcome_note']
        row << [uri, creator, date, action, note]
      end
  end
