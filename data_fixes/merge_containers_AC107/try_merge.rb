require 'archivesspace/client'
require_relative 'sandbox_auth'
require 'json'

#configure access
config = ArchivesSpace::Configuration.new({
  base_uri: "https://aspace-staging.princeton.edu/staff/api",
  base_repo: "",
  username: @user,
  password: @password,
  #page_size: 50,
  throttle: 0,
  verify_ssl: false,
})

#log in
client = ArchivesSpace::Client.new(config).login

update=client.post('/merge_requests/top_container?repo_id=4', {"target":{"ref":"/repositories/4/top_containers/64898"},"victims":[{"ref":"/repositories/4/top_containers/65214"},{"ref":"/repositories/4/top_containers/65641"}]}
)
puts update.body
