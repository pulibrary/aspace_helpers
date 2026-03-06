require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login

puts "Process started: #{Time.now}"
repo = 8
resource_id = 4113

#search for top containers by resource id
top_containers = []
top_containers << @client.get(
  "/repositories/#{repo}/top_containers/search",
    query: {
      q: "collection_uri_u_sstr:\"/repositories/#{repo}/resources/#{resource_id}\""
    }
).parsed['response']['docs']
top_containers.flatten!

#search for archival objects by resource id
ao_refs = []
ao_refs << @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed
ao_refs.flatten!

#get ao uris
ao_uris = ao_refs[0]['uris'].map {|uri| uri['ref']}.reject {|uri| uri.include? "resources"}

#select only microfilms from top_containers
microfilms = top_containers.select do |top_container|
  top_container['title'].downcase.include? "MICROFILM".downcase
end

#get microfilm uris
microfilm_uris = microfilms.map {|microfilm| microfilm['uri']}

#unlink microfilm instances from aos
ao_uris.each do |ao_uri|
  record = @client.get(ao_uri).parsed
  next if record['instances'].empty?

  record['instances'].reject! do |instance|
    microfilm_uris.any? do |microfilm_uri|
      instance['sub_container']['top_container']['ref'].include? microfilm_uri
    end
  end
  post = @client.post(ao_uri, record)
  puts post.body
end
