require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

resources = get_all_records_of_type_in_repo("resources", 8)
resources.each do |resource|
  text = "Updated during the 2026 data reconciliation project."
  add_resource_revision_statement(resource, text)
    uri = resource['uri']
    post = @client.post(uri, resource)
    puts post.body
  end

end_time = "Process ended: #{Time.now}"
puts end_time
