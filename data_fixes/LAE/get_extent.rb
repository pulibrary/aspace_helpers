require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

resources = get_all_records_of_type_in_repo("resources", 8)
resources.each do |resource|
  resource['extents'].delete_if {|extent| extent['portion']=='part' && extent['extent_type']=='items' }
  puts "#{resource['uri']}^#{resource['ead_id']}^#{resource['extents']}"
end
#puts "#{resource['uri']}^#{resource['ead_id']}^#{extent['portion']}^#{extent['number']}^#{extent['extent_type']}"

end_time = "Process ended: #{Time.now}"
puts end_time
