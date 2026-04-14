require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

puts "Process started: #{Time.now}"

#link containers to location
ids = [124396,
       124397,
       124398,
       124399,
       124400,
       124401,
       124402,
       124403,
       124404,
       124405,
       124406,
       124407,
       124408,
       124409,
       124410,
       124411,
       124412]
ids.each do |id|
  uri = "/repositories/8/top_containers/batch/location?ids[]=#{id}&location_uri=/locations/23658"
  post = @client.post(uri, {})
  puts post.body
end
