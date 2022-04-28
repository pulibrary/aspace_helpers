require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

#aardvark = get_agent_by_id('people', '32939')

#get all ids for person agents
agent_ids = @client.get('/agents/people', {
  query: {
   all_ids: true}}).parsed

#get full records for agent ids
agents = []
agent_ids.last(200).map do |agent|
  agent_record = @client.get("/agents/people/#{agent}").parsed
  agents << agent_record
end

agents.map do |agent|
#check name fields
  name_forms = []
  name_forms << agent['display_name']['primary_name']
  name_forms << agent['display_name']['sort_name']
  name_forms << agent['title']
  agent['names'].map do |name|
    name_forms << name['primary_name']
    name_forms << name['rest_of_name']
    name_forms << name['sort_name']
    name_forms << name['fuller_form']
    name_forms << name['title']
    name_forms << name['prefix']
    name_forms << name['suffix']
    name['parallel_names'].map do |parallel_name|
      name_forms << parallel_name['primary_name']
      name_forms << parallel_name['rest_of_name']
      name_forms << parallel_name['fuller_form']
      name_forms << parallel_name['title']
      name_forms << parallel_name['prefix']
      name_forms << parallel_name['suffix']
    end
  end

  match = name_forms.grep(/mrs\.|ms\.\s|miss[,\s]/i)
  unless match.empty?
    puts "#{agent['uri']}, #{agent['title']}, '#{match}'"
  else "not found"
  end
end
