require 'archivesspace/client'
require 'json'
require 'csv'
require 'aspace_helper_methods'

aspace_login

update = @client.post('/merge_requests/top_container?repo_id=8', {
                        merge_destination: {ref: "/repositories/8/top_containers/109813"},
  merge_candidates: [
    {ref: "/repositories/8/top_containers/109812"},
    {ref: "/repositories/8/top_containers/109814"},
    {ref: "/repositories/8/top_containers/109815"}
  ]
                      })
puts update.body
