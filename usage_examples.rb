require 'archivesspace/client'
require 'json'
require_relative 'helper_methods.rb'

aspace_login()

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
