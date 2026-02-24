require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login

puts "Process started: #{Time.now}"

#link containers to location
ids = [123302,
       123303,
       123304,
       123305,
       123306,
       123307,
       123308,
       123309,
       123310,
       123311,
       123312,
       123313,
       123314,
       123315,
       123316,
       123317,
       123318,
       123319,
       123320,
       123321,
       123322,
       123323,
       123324,
       123325,
       123326,
       123327,
       123328,
       123329,
       123330,
       123331,
       123332,
       123333,
       123334,
       123335,
       123336,
       123337,
       123338,
       123339,
       123340,
       123341,
       123342,
       123343,
       123344,
       123345]
ids.each do |id|
  uri = "/repositories/8/top_containers/batch/location?ids[]=#{id}&location_uri=/locations/23653"
  post = @client.post(uri, {})
  puts post.body
end
