require 'archivesspace/client'
require_relative 'sandbox_auth'

#configure access
config = ArchivesSpace::Configuration.new({
  base_uri: "https://aspace.princeton.edu/staff/api",
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
#file_ids = [2044, 2140, 2141, 2152, 2158, 2159, 2160, 2161, 2162, 2163, 2164, 2142, 2143, 2144, 2145, 2146, 2147]
#file_ids = [2152]
#this doesn't scale
#containers_all = []
#file_ids.each do |file|
#  containers_all << client.get('/repositories/4/resources/2152/top_containers', {
#    query: {
#    all_ids: true
#    }}).parsed
#end

#Lyrasis recommends this
file_ids = [2044, 2140, 2141, 2152, 2158, 2159, 2160, 2161, 2162, 2163, 2164, 2142, 2143, 2144, 2145, 2146, 2147]
top_container_uris = []
file_ids.each do |id|
  top_container_uris << client.get(
  'repositories/4/top_containers/search',
  #need to use two sets of double quotes to allow query parameters to use interpolation
  query: { q: "collection_uri_u_sstr:\"/repositories/4/resources/#{id}\"" }
  ).parsed['response']['docs'].map { |result| { "ref" => result['uri'] } }
  end

top_container_uris.each do |uri|
  puts uri
end

puts top_container_uris
