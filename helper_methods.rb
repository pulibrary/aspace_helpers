#!/usr/bin/env ruby
require 'archivesspace/client'

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
  repositories.map {|repo| repo['uri']}
end

def get_repo_id_from_uri(uri)
  uri.gsub('/repositories/', '')
end

def get_resource_ids_for_all_repos
  repos = get_all_repo_uris
  @ids = []
  repos.each do |repo|
    @ids << @client.get("#{repo}/resources", {
      query: {
        all_ids: true
      }}).parsed
  end
  @ids.flatten!
end

def get_resource_uris_for_all_repos
  @uris = get_all_repo_uris.map do |repo|
    ids = @client.get("#{repo}/resources", {
    query: {
      all_ids: true
    }}).parsed
    ids.map do |id|
      "#{repo}/resources/#{id}"
    end
  end
  @uris.flatten!
end

def add_ids_to_array(repo, record_type)
  @ids = []
  @ids << @client.get("repositories/#{repo}/#{record_type}", {
    query: {
      all_ids: true
    }}).parsed
  @ids = @ids.flatten!
end

def get_resource_uris_for_specific_repos(repos = [])
  @uris = []
  repos.each do |repo|
    add_ids_to_array(repo, 'resources')
    @ids.each do |id|
      @uris << "repositories/#{repo}/resources/#{id}"
    end
  end
  @uris
end 

def get_all_resource_records_for_institution(resolve = [])
  repos = get_all_repo_uris
  repos.map do |repo|
    repo_id = get_repo_id_from_uri(repo)
    resource_ids = add_ids_to_array(repo_id, 'resources')
    count_ids = resource_ids.count
    paginate_endpoint(resource_ids, count_ids, "#{repo}/resources", resolve)
  end.flatten
end 

def paginate_endpoint(ids, count_ids, endpoint, resolve)
  @results = []
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
  @results.flatten
end

def get_all_records_of_type_in_repo(record_type, repo, resolve = [])
  get_paginated_records(record_type, repo, resolve)
  @results.flatten!
end

def construct_endpoint(repo, record_type)
  endpoint = 'repositories/'+repo.to_s+'/'+record_type.to_s
end

def get_paginated_records(record_type, repo, resolve)
  endpoint = construct_endpoint(repo, record_type)
  ids = []
  ids << @client.get(endpoint, {
    query: {
     all_ids: true
    }}).parsed
  count_ids = ids.flatten!.count
  paginate_endpoint(ids, count_ids, endpoint, resolve)
end

def get_single_resource_by_eadid(repo, eadid, resolve = [])
  record_type = 'resources'
  collections_all = get_all_records_of_type_in_repo(record_type, repo, resolve)
  selected_resources = collections_all.select do |c|
    c['ead_id'] == eadid
  end
end

#pass in eadids as array
def get_uris_by_eadids(eadids, resolve = [])
  selected_resources = get_resources_by_eadids(eadids, resolve)
  uris = selected_resources.flatten.map do |resource| 
    "#{resource['uri']}, #{resource['ead_id']}"
  end
end

#pass in eadids as array
def get_resources_by_eadids(eadids, resolve = [])
  selected_resources = []
  selected_resources << get_all_resource_records_for_institution.select do |resource| 
    eadids.include? resource['ead_id']
  end
  selected_resources
end

def get_person_by_id_as_xml(repo_id, agent_id)
endpoint_name = '/repositories/' + repo_id.to_s + '/archival_contexts/people/' + agent_id.to_s + '.xml'
@client.get(endpoint_name.to_s).parsed
end

#expect this method to take up to 30 minutes
def get_all_top_container_records_for_institution(resolve = [])
  repos = get_all_repo_uris
  repos.map do |repo_uri|
    repo_id = get_repo_id_from_uri(repo_uri)
    container_ids = add_ids_to_array(repo_id, 'top_containers')
    count_ids = container_ids.count
    paginate_endpoint(container_ids, count_ids, "#{repo_uri}/top_containers", resolve)
  end.flatten
end 

def get_users
  endpoint_name = '/users'
  ids = @client.get('/users', {
    query: {
     all_ids: true
    }}).parsed.join(',')
  users = @client.get('/users', {
    query: {
      id_set: ids
    }
    }).parsed
end

def get_user_permissions
  ids = @client.get('/users', {
      query: {
       all_ids: true
      }}).parsed
  ids.map { |id| @client.get("/users/#{id}").parsed }
end

def add_agent_maintenance_history(record, text)
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

def get_index_of_resource_uri(uri)
  repo = uri.gsub('repositories/', '').gsub(/\/resources\/.+/, '')
  uris = get_resource_uris_for_specific_repos([repo])
  uris.index(uri)
end

#input_ids and record_types_to_prefetch are passed in as arrays
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
