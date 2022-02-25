require 'archivesspace/client'
require_relative 'helper_methods.rb'

client = aspace_login(@staging)
repos = client.get('repositories')

repos.parsed.each do |repo|
  puts repo['repo_code']
end
