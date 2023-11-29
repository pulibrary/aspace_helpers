require 'archivesspace/client'
require 'active_support/all'
require_relative 'helper_methods.rb'

aspace_login

repos = @client.get('/repositories').parsed
eng = repos[6]
uri = eng['uri']
eng['slug'] = "eng"
post = @client.post(uri, eng.to_json)
puts post.body
