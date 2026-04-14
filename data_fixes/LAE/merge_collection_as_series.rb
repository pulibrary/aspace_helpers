require 'archivesspace/client'
require 'active_support/all'
#require 'json'
#require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login

puts "Process started: #{Time.now}"

merge_destination_id = 4083
merge_destination_record = @client.get("/repositories/8/resources/#{merge_destination_id}", query: {
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
      resource: {ref: merge_destination_uri}
                      })
 puts post.body
end

