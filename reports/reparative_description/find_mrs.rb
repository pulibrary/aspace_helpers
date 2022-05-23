require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

output_file = "mrs_out.csv"

CSV.open(output_file, "a",
         :write_headers => true,
         :headers => ["uri", "title", "match_in_names", "match_in_bioghist"]) do |row|

  #get all ids for person agents
  agent_ids = @client.get('/agents/people', {
    query: {
     all_ids: true}}).parsed

  #get full records for agent ids
  agents = []
  agent_ids.map do |agent|
    agent_record = @client.get("/agents/people/#{agent}").parsed
    agents << agent_record
  end

  agents.map do |agent|
  #check name fields and bioghist
    name_forms = []
    bioghist = []
    name_forms << agent['display_name']['primary_name']
    name_forms << agent['display_name']['sort_name']
    name_forms << agent['title']
    bioghist << agent['notes'].map { |note| note['subnotes'].map {|subnote| subnote['content'] if note['jsonmodel_type'] == "note_bioghist"}}
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

    match_name = name_forms.grep(/((mrs\.?|miss)([,\s]|$))|((,?\sms\.?)(\s|$))|(^ms\.?\s)/i)
    #don't use start or end of field to filter notes
    match_note = bioghist.flatten!.grep(/((mrs\.?|miss)[,\s])|(,?\sms\.?\s)|(ms\.?\s)/i)
    unless match_name.empty? && match_note.empty?
      row << [agent['uri'], agent['title'], "'"+match_name.join("', '")+"'", "'"+match_note.join("', '")+"'"]
      puts "#{agent['uri']}, #{agent['title']}, '#{match_name.join("', '")}', '#{match_note.join("', '")}'"
    end
  end
end

end_time = "Process ended #{Time.now}."
puts end_time
