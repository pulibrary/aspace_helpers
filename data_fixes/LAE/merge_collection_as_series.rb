require 'archivesspace/client'
require 'active_support/all'
#require 'json'
#require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login

puts "Process started: #{Time.now}"

merge_destination_id = 4083
merge_destination_record = @client.get('/repositories/8/resources/'+merge_destination_id.to_s, query: {
                resolve: []
              }).parsed
merge_destination_uri = merge_destination_record['uri']
merge_candidate_uris = ['/repositories/8/resources/4084']

#create a series for each merge candidate
merge_candidate_uris.each do |candidate_uri|
  candidate_record = @client.get(candidate_uri).parsed
  post = @client.post('/repositories/8/archival_objects', {
      title: candidate_record['title'],
      level: 'series',
      publish: true,
      external_ids: candidate_record['external_ids'],
      subjects: candidate_record['subjects'],
      linked_events: candidate_record['linked_events'],
      extents: candidate_record['extents'],
      lang_materials: candidate_record['lang_materials'],
      dates: candidate_record['dates'],
      external_documents: candidate_record['external_documents'],
      rights_statements: candidate_record['rights_statements'],
      linked_agents: candidate_record['linked_agents'],
      #'is_slug_auto': True,
      #'restrictions_apply': False,
      #'ancestors': [],
      instances: candidate_record['instances'],
      notes: candidate_record['notes'],
      #'ref_id': "20029191", 
      resource: {'ref': merge_destination_uri}
 })
 puts post.body
#  new_series_id = post.body['id']
# get tree information for the candidate resource
#  candidate_ao_tree = @client.get(candidate_uri+'/ordered_records').parsed['uris']
# get the ao uris from the candidate tree and set their resource to the new destination resource
#  all_candidate_ao_uris = candidate_ao_tree.map { |ao| ao['ref']}
#  all_candidate_ao_uris.each do |candidate_ao_uri|
#   candidate_ao_record = @client.get(candidate_ao_uri).parsed
#   candidate_ao_record['resource'] = {"ref": merge_destination_uri}
#   next if candidate_ao_record.key?('parent')
#   candidate_ao_record['parent'] = {"ref": "/archival_objects/#{new_series_id}"}
#   @client.post(candidate_ao_uri, candidate_ao_record)
#  end
#identify top-level aos and 
# top_level_ao_uris = aos_to_move.select { |ao| ao['depth'] == 1 }.map { |ao| ao['ref'] }




 end

# end
#Move existing Archival Objects to become children of a Resource
# merge_candidate_uris.each do |candidate_uri|
  #get the top-level ao's
  # aos = @client.get(candidate_uri+'/tree/root').parsed
  # #add the top-level ao uri's to an array
  # ao_uris = []
  # aos['precomputed_waypoints']['']['0'].each do |ao| 
  #   ao_uris << ao['uri']
  # end
  #post the ao uri's to the destination resource uri

# end

# Generate the archival object tree for a resource
# [:GET] /bulk_archival_object_updater/repositories/:repo_id/resources/:id/small_tree

# The accept_children endpoint is broken, else we would do:
#   url = "/repositories/8/resources/4083/accept_children"
#   post = @client.post(url, data)
  # url = "/repositories/8/resources/4083/accept_children?position=3&children[]=/repositories/8/archival_objects/1258960"
  # post = @client.post(url, {})


#[:POST] /merge_requests/resource
# update=client.post('/merge_requests/top_container?repo_id=8', {
#   "target":{"ref":"/repositories/8/top_containers/110015"},
#   "victims":[
#     {"ref":"/repositories/8/top_containers/110016"},
#     {"ref":"/repositories/4/top_containers/110017"}
#   ]
# }
# )
# update=@client.post('/merge_requests/top_container?repo_id=4', {
#       uri: 'merge_requests/top_container',
#       target: {ref: target},
#       victims: [{ref: victim}]
#     }.to_json)



