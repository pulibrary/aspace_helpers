require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

puts Time.now
@client = aspace_login
output_file = "subjects_test.csv"

subject_ids = @client.get(
  "/subjects", { query: { all_ids: true } }
).parsed
subjects =
  subject_ids.map {|subject_id| @client.get("/subjects/#{subject_id}").parsed}

CSV.open(output_file, "a",
           :write_headers => true,
           :headers => ["title", "created", "source", "type", "ext_ids", "used", "terms", "vocab", "uri"]) do |row|
subject_fields = subjects.map do |subject|
  title = subject['title']
  created = subject['create_time']
  source = subject['source']
  type = subject['jsonmodel_type']
  ext_ids = subject['external_ids'][0..].map do |id|
    "#{id['source']}: #{id['external_id']} "
  end
  used = subject['used_within_repositories']
  terms = subject['terms'][0..].map do |term|
    "#{term['term']} (#{term['term_type']})"
  end
  vocab = subject['vocabulary']
  uri = subject['uri']
  row << [title, created, source, type, ext_ids, used, terms, vocab, uri]
end
end
puts Time.now
