require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'aspace_helper_methods'

aspace_staging_login

update=client.post('/merge_requests/top_container?repo_id=8', {
  "target":{"ref":"/repositories/8/top_containers/110015"},
  "victims":[
    {"ref":"/repositories/8/top_containers/110016"},
    {"ref":"/repositories/4/top_containers/110017"}
  ]
}
)
puts update.body
