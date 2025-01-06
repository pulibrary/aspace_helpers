require 'archivesspace/client'
require_relative '../sandbox_auth'
require 'json'

#configure access
config = ArchivesSpace::Configuration.new({
  base_uri: @baseURL,
  base_repo: "",
  username: @user,
  password: @password,
  #page_size: 50,
  throttle: 0,
  verify_ssl: false,
})

#log in
client = ArchivesSpace::Client.new(config).login

#get all container ids for AC107.xx
file_ids = [2044, 2140, 2141, 2152, 2158, 2159, 2160, 2161, 2162, 2163, 2164, 2142, 2143, 2144, 2145, 2146, 2147]
#file_ids = [2044, 2041, 2146, 2147]#

#this doesn't scale
#containers_all = []
#file_ids.each do |file|
#  containers_all << client.get('/repositories/4/resources/2152/top_containers', {
#    query: {
#    all_ids: true
#    }}).parsed
#end

#Lyrasis recommends this instead
#top_container_uris = client.get(
#  'repositories/4/top_containers/search',
#  query: { q: 'collection_uri_u_sstr:"/repositories/4/resources/2152"' }
#).parsed['response']['docs'].map { |result| { "ref" => result['uri'] } }

#top_container_uris.each do |uri|
#  puts uri
#end

#search across all the top containers in the repository for AC107 containers; get indicator and uri
top_containers = file_ids.map do |id|
  client.get(
  'repositories/4/top_containers/search',
  #need to use two sets of double quotes to allow query parameters to use interpolation
  query: { q: "collection_uri_u_sstr:\"/repositories/4/resources/#{id}\"" }
  #the json field, counter-intuitively, is a string; parse as json
).parsed['response']['docs'].map { |result| { JSON.parse(result['json'])['indicator'] => result['uri'] } }
end

#flatten response array and group by box number string (we know they are all of type "box")
top_containers = top_containers.flatten!
top_containers_grouped = {}
top_containers.each do |hash|
   hash.each_key do |k|
     if top_containers_grouped.has_key?(k) == false
     then top_containers_grouped.store(k, [])
     end
     #instead of storing top_containers_grouped[k] << hash[k], need to hash uris with key "ref"
     ref = {}
     ref.store("ref", hash[k])
     top_containers_grouped[k] << ref
   end
end

#puts top_containers_grouped
#for each group, take first as target, following as victims, and merge victims into target
top_containers_grouped = top_containers_grouped.select {|k,v| v.count > 1}
top_containers_grouped.each_value do|v|
  target =
      v[0]
  victims =
      v.drop(1)
  query = {
    target: target,
    victims: victims
  }

  update = client.post('/merge_requests/top_container?repo_id=4', query)
  puts update.body
end
