#!/usr/bin/env ruby
require 'archivesspace/client'
#require_relative 'authentication'

def aspace_login()
  #configure access
  @config = ArchivesSpace::Configuration.new({
    base_uri: ENV.fetch('ASPACE_URL', nil),
    base_repo: "",
    username: ENV.fetch('ASPACE_USER', nil),
    password: ENV.fetch('ASPACE_PASSWORD', nil),
    #page_size: 50,
    throttle: 0,
    verify_ssl: false
  })
  #log in
  @client = ArchivesSpace::Client.new(@config).login
end

def aspace_staging_login()
  #configure access
  @config = ArchivesSpace::Configuration.new({
    base_uri: ENV.fetch('ASPACE_STAGING_URL', nil),
    base_repo: "",
    username: ENV.fetch('ASPACE_USER', nil),
    password: ENV.fetch('ASPACE_PASSWORD', nil),
    #page_size: 50,
    throttle: 0,
    verify_ssl: false,
  })

  #log in
  @client = ArchivesSpace::Client.new(@config).login
end

def get_all_repo_uris
  repositories = @client.get('/repositories').parsed
  repositories.map do |repo|
    repo['uri']
  end
end

def get_all_resource_records_for_institution(resolve = [])
  resources_endpoints = get_all_repo_uris.map do |repo|
    repo+'/resources'
    end
  @results = []
  resources_endpoints.each do |endpoint|
    @ids_by_endpoint = []
    @ids_by_endpoint << @client.get(endpoint, {
      query: {
       all_ids: true
      }}).parsed
    @ids_by_endpoint = @ids_by_endpoint.flatten!
    count_ids = @ids_by_endpoint.count
    paginate_endpoint(@ids_by_endpoint, count_ids, endpoint, resolve)
  end 
  @results = @results.flatten!
end 

def get_all_event_records_for_institution(resolve = [])
  #run through all repositories (1 and 2 are reserved for admin use)
  resources_endpoints = get_all_repo_uris.map do |repo|
    repo+'/events'
    end
  #debug
  #puts "endpoints to process are:"
  #puts resources_endpoints

  #for each endpoint, get the count of records
  @results = []
  resources_endpoints.each do |endpoint|
    @ids_by_endpoint = []
    @ids_by_endpoint << @client.get(endpoint, {
      query: {
       all_ids: true
      }}).parsed
    @ids_by_endpoint = @ids_by_endpoint.flatten!
    count_ids = @ids_by_endpoint.count
    #debug
    #puts "number of records to retrieve for #{endpoint}:"
    #puts count_ids

    #for each endpoint, get the record by id and add to array of records
    paginate_endpoint(@ids_by_endpoint, count_ids, endpoint, resolve)
  end #close resources_endpoints.each

  #return array of results
  @results = @results.flatten!
end #close method

def paginate_endpoint(ids, count_ids, endpoint, resolve)
  count_processed_records = 0
  while count_processed_records < count_ids do
    last_record = [count_processed_records+249, count_ids].min
    @results << @client.get(endpoint, {
            query: {
              id_set: ids[count_processed_records..last_record],
              resolve: resolve
            }
          }).parsed
    count_processed_records = last_record
  end
end

def construct_endpoint(repo, endpoint_name)
  endpoint = 'repositories/'+repo.to_s+'/'+endpoint_name.to_s
end

def get_paginated_records(repo, endpoint_name, resolve)
  @results = []
  #get endpoint
  endpoint = construct_endpoint(repo, endpoint_name)
  #get all ids
  ids = []
  ids << @client.get(endpoint, {
    query: {
     all_ids: true
    }}).parsed
  #get a count of ids
  count_ids = ids.flatten!.count

  #for each id, get the record and add to array of records
  paginate_endpoint(ids, count_ids, endpoint, resolve)
end

def get_all_records_for_repo_endpoint(repo, endpoint_name, resolve = [])
  get_paginated_records(repo, endpoint_name, resolve)
  @results.flatten!
end

def get_single_resource_by_id(repo, id, resolve = [])
  endpoint_name = '/resources/'
  endpoint = construct_endpoint(repo, endpoint_name)
  id = id.to_s
  @client.get(endpoint + id,{
    query: {
     id_set: id,
     resolve: resolve
    }}).parsed
end

def get_single_archival_object_by_id(repo, id, resolve = [])
    endpoint_name = '/archival_objects/'
    endpoint = construct_endpoint(repo, endpoint_name)
    id = id.to_s
    @client.get(endpoint + id,{
      query: {
       id_set: id,
       resolve: resolve
      }}).parsed
end

def get_single_container_by_id(repo, id, resolve = [])
  endpoint_name = '/top_containers/'
  endpoint = construct_endpoint(repo, endpoint_name)
  id = id.to_s
  @client.get(endpoint + id,{
    query: {
     id_set: id,
     resolve: resolve
    }}).parsed
end

def get_single_event_by_id(repo, id, resolve = [])
  endpoint_name = '/events/'
  endpoint = construct_endpoint(repo, endpoint_name)
  id = id.to_s
  @client.get(endpoint + id,{
    query: {
     id_set: id,
     resolve: resolve
    }}).parsed
end

def get_single_do_by_id(repo, id, resolve = [])
  endpoint_name = '/digital_objects/'
  endpoint = construct_endpoint(repo, endpoint_name)
  id = id.to_s
  @client.get(endpoint + id,{
    query: {
     id_set: id,
     resolve: resolve
    }}).parsed
end

def get_single_archival_object_by_cid(repo, cid, resolve = [])
  endpoint_name = 'archival_objects'
  components_all = get_all_records_for_repo_endpoint(repo, endpoint_name, resolve)
  selected_resources = components_all.select do |c|
    c['ref_id'] == cid
  end
end

def get_single_resource_by_eadid(repo, eadid, resolve = [])
  endpoint_name = 'resources'
  collections_all = get_all_records_for_repo_endpoint(repo, endpoint_name, resolve)
  selected_resources = collections_all.select do |c|
    c['ead_id'] == eadid
  end
end

def get_uris_by_eadids(eadids, resolve = [])
  collections_all = get_all_resource_records_for_institution()
  selected_resources = []
  selected_resources << collections_all.select {|collection| eadids.include? collection['ead_id']}
  uris = selected_resources.flatten.map {|resource| "#{resource['uri']}, #{resource['ead_id']}"}
end

#get resource records by eadids
#this method assumes that there is no duplication of eadids across repositories
def get_array_of_resources_by_eadids(eadids, resolve = [])
  collections_all = get_all_resource_records_for_institution()
  selected_resources = []
  selected_resources << collections_all.select {|collection| eadids.include? collection['ead_id']}
end

def get_agent_by_id(agent_type, agent_id, resolve = [])
endpoint_name = '/agents/' + agent_type
ids = @client.get(endpoint_name.to_s, {
  query: {
   id_set: agent_id.to_s,
   resolve: resolve
   #all_ids: true
  }}).parsed
end

def get_person_by_id_as_xml(repo_id, agent_id)
endpoint_name = '/repositories/' + repo_id.to_s + '/archival_contexts/people/' + agent_id.to_s + '.xml'
@client.get(endpoint_name.to_s).parsed
end

def get_all_top_container_records_for_institution(resolve = [])
  #run through all repositories (1 and 2 are reserved for admin use)
  resources_endpoints = get_all_repo_uris.map do |repo|
    repo+'/top_containers'
    end

  #for each endpoint, get the count of records
  @results = []
  resources_endpoints.each do |endpoint|
    @ids_by_endpoint = []
    @ids_by_endpoint << @client.get(endpoint, {
      query: {
       all_ids: true
      }}).parsed
    @ids_by_endpoint = @ids_by_endpoint.flatten!
    count_ids = @ids_by_endpoint.count

    #for each endpoint, get the record by id and add to array of records
    paginate_endpoint(@ids_by_endpoint, count_ids, endpoint, resolve)
  end #close resources_endpoints.each
  @results = @results.flatten!
end

def get_all_digital_object_records_for_a_repository(repo, resolve = [])
  resources_endpoints = []
  resources_endpoints << 'repositories/'+repo.to_s+'/digital_objects'

  #for each endpoint, get the count of records
  @results = []
  resources_endpoints.each do |endpoint|
    @ids_by_endpoint = []
    @ids_by_endpoint << @client.get(endpoint, {
      query: {
       all_ids: true
      }}).parsed
    @ids_by_endpoint = @ids_by_endpoint.flatten!
    count_ids = @ids_by_endpoint.count

    #for each endpoint, get the record by id and add to array of records
    paginate_endpoint(@ids_by_endpoint, count_ids, endpoint, resolve)
  end #close resources_endpoints.each
  @results = @results.flatten!
end

def get_all_archival_objects_for_resource(repo, id, resolve = [])
  archival_objects_all = get_all_records_for_repo_endpoint(repo, 'archival_objects', resolve)
  archival_objects_filtered =
    archival_objects_all.select do |ao|
      ao['resource']['ref'] == "/repositories/#{repo}/resources/#{id}"
    end
end

#add a revision statement to a resource uri.
def add_revision_statement(uri, description)
  resource = @client.get(uri).parsed
  revision_statement =
    {"date"=>Time.now,
  	"description"=>description}
  resource['revision_statements'] = resource['revision_statements'].append(revision_statement)
  post = @client.post(uri, resource.to_json)
  puts post.body
end

def get_all_resource_uris_for_institution()
  #run through all repositories (1 and 2 are reserved for admin use)
  resources_endpoints = get_all_repo_uris.map do |repo|
    repo+'/resources'
    end
  @uris = []
  resources_endpoints.each do |endpoint|
    ids_by_endpoint = []
    ids_by_endpoint << @client.get(endpoint, {
      query: {
       all_ids: true
      }}).parsed
    ids_by_endpoint = ids_by_endpoint.flatten!
    ids_by_endpoint.each do |id|
      @uris << "/#{endpoint}/#{id}"
    end
  end #close resources_endpoints.each
  @uris
end #close method

#return a hash of users (does not include credentials)
def get_users()
  endpoint_name = '/users'
  ids = @client.get(endpoint_name, {
    query: {
     all_ids: true
    }}).parsed.join(',')
  users = @client.get(endpoint_name, {
    query: {
      id_set: ids
    }
    }).parsed
end

#return a hash of user credentials
def get_user_permissions()
  ids = @client.get('/users', {
      query: {
       all_ids: true
      }}).parsed
  ids.map { |id| @client.get("/users/#{id}").parsed }
end

#add a maintenance statement to agent records or create the field if it doesn't exist
def add_maintenance_history(record, text)
  if record['agent_maintenance_histories'].nil?
    record['agent_maintenance_histories'] = [{
      "maintenance_event_type"=>"updated",
      "maintenance_agent_type"=>"machine",
      "agent"=>"system",
      "event_date"=>"#{Time.now}",
      "descriptive_note"=>text.to_s,
      "created_by"=>"aspace_helpers",
      "publish"=>true,
      "jsonmodel_type"=>"agent_maintenance_history"
    }]
  else
    record['agent_maintenance_histories'] << {
      "maintenance_event_type"=>"updated",
      "maintenance_agent_type"=>"machine",
      "agent"=>"system",
      "event_date"=>"#{Time.now}",
      "descriptive_note"=>text.to_s,
      "created_by"=>"aspace_helpers",
      "publish"=>true,
      "jsonmodel_type"=>"agent_maintenance_history"
    }
  end
end

#add a revision statement to a resource record
def add_resource_revision_statement(record, text)
  record['revision_statements'] << {
    "date"=>"#{Time.now}",
    "created_by"=>"system",
    "last_modified_by"=>"aspace_helpers",
    "create_time"=>"#{Time.now}",
    "description"=>text.to_s,
    "publish"=>true,
    "jsonmodel_type"=>"revision_statement"
  }
end

#get resource uri's for specific repositories
#add repositories in as an array of ids
def get_all_resource_uris_for_repos(repos = [])
  resources_endpoints = repos.map do |repo|
    'repositories/'+repo.to_s+'/resources'
    end
  @uris = []
  resources_endpoints.each do |endpoint|
    ids_by_endpoint = []
    ids_by_endpoint << @client.get(endpoint, {
      query: {
       all_ids: true
      }}).parsed
    ids_by_endpoint = ids_by_endpoint.flatten!
    ids_by_endpoint.each do |id|
      @uris << "/#{endpoint}/#{id}"
    end
  end #close resources_endpoints.each
  @uris
end #close method

def get_index_of_resource_uri(uri, repo)
  uris = get_all_resource_uris_for_repos([repo])
  uris.index(uri)
end

#get linked objects from descriptive records
def get_resolved_objects_from_ids(repository_id, input_ids, record_type, record_types_to_prefetch)
  all_records = []
  count_processed_records = 0
  count_ids = input_ids.count
  while count_processed_records < count_ids
      last_record = [count_processed_records+29, count_ids].min
      all_records << @client.get("/repositories/#{repository_id}/#{record_type}",
              query: {
                id_set: input_ids[count_processed_records..last_record],
                resolve: record_types_to_prefetch
              }).parsed
      count_processed_records = last_record
  end
  all_records = all_records.flatten
end
