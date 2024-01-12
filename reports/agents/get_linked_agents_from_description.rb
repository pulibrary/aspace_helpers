require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_login

#get all resource uri's
resource_uris = get_all_resource_uris_for_institution
#get uri's for all ao's (published only)
all_uris = []
resource_uris[0..1].each do |resource_uri|
  all_uris << @client.get("#{resource_uri}/ordered_records").parsed
end
all_uris = all_uris.flatten
#get each individual uri
refs = []
all_uris.each do |hash|
  uris = hash['uris']
  refs << uris.map{ |uri| uri['ref'] }
end
refs = refs.flatten
refs[0..-1].each do |ref|
  record = @client.get(ref).parsed
#   subjects = record['subjects']
#   puts subjects
  agents = record['linked_agents']
  agents.map do |agent|
    puts "#{record['uri']}, #{agent['ref']}, #{agent['role']}, #{agent['relator']}, #{agent['terms']}"
  end unless agents.empty?
end
# resolve agents and subjects
# [{uris => {'ref'=>'123'}, {'ref'=>'234'}}, {uris => {'ref'=>'345'}, {'ref'=>'456'}}]
#report out agent/subject uri, type, resource/ao uri
