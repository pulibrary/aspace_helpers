require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'
# require_relative 'sandbox_auth'
#
# def aspace_staging_login()
#   #configure access
#   @config = ArchivesSpace::Configuration.new({
#     base_uri: @baseURL_staging,
#     base_repo: "",
#     username: @user,
#     password: @password,
#     #page_size: 50,
#     throttle: 0,
#     verify_ssl: false,
#   })
#
#   #log in
#   @client = ArchivesSpace::Client.new(@config).login
# end
#
#
# def get_all_records_for_repo_endpoint(repo, endpoint_name, resolve = [])
#   get_paginated_records(repo, endpoint_name, resolve)
#   @results.flatten!
# end
#
# def get_paginated_records(repo, endpoint_name, resolve)
#   @results = []
#   #get endpoint
#   endpoint = construct_endpoint(repo, endpoint_name)
#   #get all ids
#   ids = []
#   ids << @client.get(endpoint, {
#     query: {
#      all_ids: true
#     }}).parsed
#   #get a count of ids
#   count_ids = ids.flatten!.count
#
#   #for each id, get the record and add to array of records
#   paginate_endpoint(ids, count_ids, endpoint, resolve)
# end
#
# def construct_endpoint(repo, endpoint_name)
#   endpoint = 'repositories/'+repo.to_s+'/'+endpoint_name.to_s
# end
#
# def paginate_endpoint(ids, count_ids, endpoint, resolve)
#   count_processed_records = 0
#   while count_processed_records < count_ids do
#     last_record = [count_processed_records+249, count_ids].min
#     @results << @client.get(endpoint, {
#             query: {
#               id_set: ids[count_processed_records..last_record],
#               resolve: resolve
#             }
#           }).parsed
#     count_processed_records = last_record
#   end
# end

#ao = get_single_archival_object_by_id(3, 521207)

# ao = @client.get('/repositories/3/archival_objects/521207', query:{
#   resolve: ['repository']
#   }).parsed
# puts ao['repository']['_resolved']['repo_code']

aspace_staging_login()

aos = get_all_records_for_repo_endpoint(11, 'archival_objects', ['repository'])
puts aos[1]
