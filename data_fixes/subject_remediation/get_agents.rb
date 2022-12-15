require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

puts Time.now
@client = aspace_login
filename = "agents_test.csv"
agent_endpoints = ["software", "families", "corporate_entities", "people"]

CSV.open(filename, "a",
           :write_headers => true,
           :headers => ["title", "created", "used", "source", "type", "ext_id", "string", "uri"]) do |row|

 agent_endpoints.map do |endpoint|
   ids = @client.get(
       "/agents/#{endpoint}", {query: {
         all_ids: true
           }
         }
       ).parsed
   agents = ids.map do |id|
     agent = @client.get("/agents/#{endpoint}/#{id}").parsed
     title = agent['title']
     created = agent['create_time']
     used = agent['used_within_repositories']
     uri = agent['uri']
     names = agent['names'][0..].map do |name|
       source = name['source']
       ext_id = name['authority_id']
       string = name['primary_name']
       type = name['jsonmodel_type']
       #puts "#{title}, #{created}, #{used}, #{source}, #{type}, #{ext_id}, #{string}, #{uri}"
       row << [title, created, used, source, type, ext_id, string, uri]
       end
     end
   end
 end

puts Time.now
