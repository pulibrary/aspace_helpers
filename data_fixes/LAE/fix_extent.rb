require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

resources = get_all_records_of_type_in_repo("resources", 8)
resources.each do |resource|
  extents = resource['extents']
  extents.each do |extent|
    if extents.count == 2 && extent['portion'] == 'part'
      extent['portion'] = 'whole'
    end
  end
  post = @client.post(resource['uri'], resource)
  puts post.body
end

end_time = "Process ended: #{Time.now}"
puts end_time
