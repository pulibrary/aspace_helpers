require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'

aspace_staging_login()

#get all resource records for the institution
#all_resources = get_all_resource_records_for_institution
#puts all_resources

#get all records for a given endpoint in a repo, by endpoint name
#collections = get_all_records_for_repo_endpoint(11, "resources")
#collections.each {|collection| puts collection['ead_id']}

#get eadids for all records for a given endpoint in a repo, by endpoint name
#collections = get_all_records_for_repo_endpoint(11, "resources")
#collections.each {|collection| puts collection['ead_id']}

#get the first ten archival object records of repo 11
#NB this is very slow
#components = get_all_records_for_repo_endpoint(11, "archival_objects")
#puts components[0..9]

#get a single resource record by id
#resource = get_single_resource_by_id(3, 1698)
#puts resource

#get a single container record by id
#component = get_single_archival_object_by_id(11, 254707)
#puts component

#get a single component record by cid
#component = get_single_archival_object_by_cid(11, 'GC186_c0001')
#puts component

#get all events lacking linked records and write to CSV
#events_all = get_all_event_records_for_institution()
#puts events_all[0]
#selected_events =
#  events_all.select {|event| event['linked_records'].empty? == true}
#puts selected_events.count
#filename = "orphaned_events.csv"
#CSV.open(filename, "wb",
#    :write_headers=> true,
#    :headers => ["uri"]) do |row|
#puts selected_events[0]['uri']
#      selected_events.each do |event|
#        uri = event['uri']
#        row << [uri]
#      end
#  end

#get a single event by id
event = get_single_event_by_id(5, 16485)
puts event
