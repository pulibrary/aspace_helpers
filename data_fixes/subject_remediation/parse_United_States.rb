require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

puts Time.now

aspace_login

subject_ids = @client.get(
  "/subjects", { query: { all_ids: true } }
).parsed

subjects_all =
  subject_ids.map {|subject_id| @client.get("/subjects/#{subject_id}").parsed}

subjects = []
subjects << subjects_all.select do |subject| 
    subject['terms'][0]['term'] =~ /--\s?United States/i
  end

subjects.flatten!.each do |subject|
  puts "#{subject['uri']}^#{subject['terms'].map { |term| term['term'] + "^" + term['term_type']}.join('^')}"  
end
  # parse_subject_string = 
#   subjects.each do |subject|
#   terms = [subject['terms'][0]]

#   end

puts Time.now
