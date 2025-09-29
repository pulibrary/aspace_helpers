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
#this works
def get_all_repo_uris
  repositories = @client.get('/repositories').parsed
  repositories.map {|repo| repo['uri']}
end
#this works
def get_repo_id_from_uri(uri)
  uri.gsub('/repositories/', '')
end

#this works
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
#this works
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
#this works
def add_ids_to_array(repo, record_type)
  @ids = []
  @ids << @client.get("repositories/#{repo}/#{record_type}", {
    query: {
      all_ids: true
    }}).parsed
  @ids = @ids.flatten!
end
#this works
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
#this works (hands off to paginate_endpoint)
def get_all_resource_records_for_institution(resolve = [])
  repos = get_all_repo_uris
  repos.map do |repo|
    repo_id = get_repo_id_from_uri(repo)
    resource_ids = add_ids_to_array(repo_id, 'resources')
    count_ids = resource_ids.count
    paginate_endpoint(resource_ids, count_ids, "#{repo}/resources", resolve)
  end
end 
#this works (returns records)
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
#this works
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

def get_single_archival_object_by_cid(repo, cid, resolve = [])
  endpoint_name = 'archival_objects'
  components_all = get_all_records_of_type_in_repo(type, repo, resolve)
  selected_resources = components_all.select do |c|
    c['ref_id'] == cid
  end
end

def get_single_resource_by_eadid(repo, eadid, resolve = [])
  endpoint_name = 'resources'
  collections_all = get_all_records_of_type_in_repo(type, repo, resolve)
  selected_resources = collections_all.select do |c|
    c['ead_id'] == eadid
  end
end

#error: add ids to array L49
def get_uris_by_eadids(eadids, resolve = [])
  selected_resources = []
  selected_resources << get_all_resource_records_for_institution.select {|collection| eadids.include? collection['ead_id']}
  uris = selected_resources.flatten.map {|resource| "#{resource['uri']}, #{resource['ead_id']}"}
end

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
  }}).parsed
end

def get_person_by_id_as_xml(repo_id, agent_id)
endpoint_name = '/repositories/' + repo_id.to_s + '/archival_contexts/people/' + agent_id.to_s + '.xml'
@client.get(endpoint_name.to_s).parsed
end

def get_all_top_container_records_for_institution(resolve = [])
  @results = []
  get_resource_uris_for_all_repos.each do |uri|
    add_ids_to_array
    count_ids = @ids.count
    paginate_endpoint(@ids, count_ids, uri, resolve)
  end 
  @results = @results.flatten!
end

def get_all_digital_object_records_for_a_repository(repo, resolve = [])
  @results = []
  get_resource_uris_for_all_repos.each do |uri|
    add_ids_to_array
    count_ids = @ids.count
    paginate_endpoint(@ids, count_ids, uri, resolve)
  end 
  @results = @results.flatten!
end

def get_all_archival_objects_for_resource(repo, id, resolve = [])
  archival_objects_all = get_all_records_of_type_in_repo('archival_objects', repo, resolve)
  archival_objects_filtered =
    archival_objects_all.select do |ao|
      ao['resource']['ref'] == "/repositories/#{repo}/resources/#{id}"
    end
end

def add_revision_statement(uri, description)
  resource = @client.get(uri).parsed
  revision_statement =
    {"date"=>Time.now,
  	"description"=>description}
  resource['revision_statements'] = resource['revision_statements'].append(revision_statement)
  post = @client.post(uri, resource.to_json)
  puts post.body
end

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

def get_user_permissions()
  ids = @client.get('/users', {
      query: {
       all_ids: true
      }}).parsed
  ids.map { |id| @client.get("/users/#{id}").parsed }
end

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



def get_index_of_resource_uri(uri, repo)
  uris = get_all_resource_uris_for_repos([repo])
  uris.index(uri)
end

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
