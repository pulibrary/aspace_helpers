require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

puts Time.now

aspace_login

subject_ids = @client.get(
  "/subjects", { query: { all_ids: true } }
).parsed

subjects =
  subject_ids.map {|subject_id| @client.get("/subjects/#{subject_id}").parsed}

subjects.each do |subject|
  next if subject['terms'].count <2
  next if subject['terms'][1]['term_type'] != "genre_form"

  uri = subject['uri']
  next unless subject['terms'][1]['term_type'] == "genre_form"

  terms = [subject['terms'][0]]
  subject['terms'][1..].reverse.map {|term| terms << term}
  subject['terms'] = terms
  add_maintenance_history(subject, "Subjects remediation: put genre/form last")
  post = @client.post(uri, subject.to_json)
end

puts Time.now
