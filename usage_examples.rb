require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'

aspace_login()

#get all resource records for the institution
all_resources = get_all_resource_records_for_institution
puts all_resources

#get all records for a given endpoint in a repo, by endpoint name
collections = get_all_records_for_repo_endpoint(11, "resources")
collections.each {|collection| puts collection['ead_id']}

#get eadids for all records for a given endpoint in a repo, by endpoint name
collections = get_all_records_for_repo_endpoint(11, "resources")
collections.each {|collection| puts collection['ead_id']}

#get the first ten archival object records of repo 11
#NB this is very slow
components = get_all_records_for_repo_endpoint(11, "archival_objects")
puts components[0..9]

#get a single resource record by id
resource = get_single_resource_by_id(3, 1698)
puts resource

#get a single container record by id
component = get_single_archival_object_by_id(11, 254707)
puts component

#get a single component record by cid
component = get_single_archival_object_by_cid(11, 'GC186_c0001')
puts component

#get all events lacking linked records and write to CSV
events_all = get_all_event_records_for_institution()
#puts events_all[0]
selected_events =
  events_all.select {|event| event['linked_records'].empty? == true}
puts selected_events.count
filename = "orphaned_events.csv"
CSV.open(filename, "wb",
    :write_headers=> true,
    :headers => ["uri"]) do |row|
puts selected_events[0]['uri']
      selected_events.each do |event|
        uri = event['uri']
        row << [uri]
      end
  end

#get a single event by id
event = get_single_event_by_id(5, 16485)
puts event

#get a single resource by ead_id and return its uri
resource = get_single_resource_by_eadid(11, "GC186")
result = resource.each.map  {|r| { r["ead_id"] => r["uri"] }}
puts result

#get a hash of eadids/uri's for a list of eadids
eadids = ["MC016", "MC200", "AC195", "AC102", "AC067", "AC100", "AC366", "AC068", "AC047", "C0910", "C1491", "C1384", "C1373", "C1436", "C1588", "C1592", "C1449", "C1599", "C0945", "C0902", "C0760", "C1381"]
result =
resources_all = get_array_of_resources_by_eadids(eadids)
resources_all.each do |resource_by_eadid|
  resource_by_eadid.each.map  {|r| puts r['ead_id'] => r['uri']}
end
#puts result

#add a revision statement to a resource record
uris.each do |uri|
  resource= @client.get(uri).parsed
  revision_statement = add_revision_statement(uri, "test")
end

#delete all instances from an archival archival_object
csv.each do |row|
  #puts row['ao_uri']
  uri = row['ao_uri']
  ao = @client.get(uri).parsed
    ao['instances'] = []
  post = @client.post(uri, ao.to_json)
  response = post.body
  puts response
end

#delete top containers by uris
csv.each do |row|
  uri = row['tc_uri']
  post = @client.delete(uri)
  response = post.body
  puts response
end

#get ids of all agent records
agents = @client.get("/agents/corporate_entities", {
  query: {
   #all_ids: true
   id_set: 4984
  }}).parsed
puts agents

#use the resolve parameter to get e.g. digital object instance records
ao = get_single_archival_object_by_id(5, 4016, ['digital_object'])
puts ao

# model for the search API
record = @client.get(
  "repositories/12/top_containers/search",
    query: { q: "collection_uri_u_sstr:\"/repositories/12/resources/1467\"" }
).parsed['response']
puts record

#get linked objects from any record id
record_types_to_prefetch = ["linked_agents", "subjects"]
record_types = ["archival_objects", "resources", "events", "accessions", "digital_objects"]

def get_resolved_objects_from_ids(repository_id, input_ids, record_type, record_types_to_prefetch)

