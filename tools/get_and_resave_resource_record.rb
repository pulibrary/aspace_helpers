require 'archivesspace/client'
require 'active_support/all'
require_relative 'helper_methods.rb'

@client = aspace_login

log = "log_benchmark.txt"
repos = (12..12).to_a

File.write(log, Time.now, mode: 'a')

#iterate over repositories
repos.each do |repo|
#iterate over all resources within repositories
resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    uri = resource['uri']
    post = @client.post(uri, resource.to_json)
    puts post.body
    File.write(log, post.body, mode: 'a')
  end
end

File.write(log, Time.now, mode: 'a')
