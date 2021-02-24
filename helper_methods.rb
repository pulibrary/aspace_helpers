#!/usr/bin/env ruby
#require 'archivesspace/client'
require_relative 'sandbox_auth'

def aspace_login()
  #configure access
  @config = ArchivesSpace::Configuration.new({
    base_uri: @baseURL,
    base_repo: "",
    username: @user,
    password: @password,
    #page_size: 50,
    throttle: 0,
    verify_ssl: false,
  })

  #log in
  @client = ArchivesSpace::Client.new(@config).login
end

def get_all_resource_records
  #run through all repositories
  resources_endpoints = []
  repos_all = (3..12).to_a
  repos_all.each do |repo|
    resources_endpoints << 'repositories/'+repo.to_s+'/resources'
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
    count_processed_records = 0
    while count_processed_records < count_ids do
      last_record = [count_processed_records+249, count_ids].min
      @results << @client.get(endpoint, {
              query: {
                id_set: @ids_by_endpoint[count_processed_records..last_record]
              }
            })
      count_processed_records = last_record
    end #close while
  end #close resources_endpoints.each

  #return array of results
  return @results
end #close method
