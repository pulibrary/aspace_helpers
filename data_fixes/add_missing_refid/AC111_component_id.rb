require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../helper_methods.rb'

aspace_staging_login()

component = get_single_archival_object_by_id(4, 711423)
component['ref_id'] = 'AC111_c0468'
post = @client.post('/repositories/4/archival_objects/711423', component.to_json)
puts post.body
