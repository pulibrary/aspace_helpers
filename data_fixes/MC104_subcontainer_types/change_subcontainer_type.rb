require 'archivesspace/client'
require 'active_support/all'
require_relative 'helper_methods.rb'

@client = aspace_login

series = @client.get("/repositories/3/archival_objects/578617/children").parsed
series.each do |ao|
    uri = ao['uri']
    ao['instances'].each do |link|
        link['sub_container']['type_2'] = "Item" unless link['sub_container'].nil?
    end
    post = @client.post(uri, ao)
    puts post.body
end
