require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

puts Time.now

csv = CSV.parse(File.read("topical_United_States.csv"), :headers=>true, :return_headers=>true)

csv.each do |row|
  uri = row[0]
  terms = []
  row.each_with_index do |field, i|
    #get the main term and its term type
    next if i <= 1

    if i == 2
      terms << {
        "term"=>field[1],
        "term_type"=>row[1],
        "jsonmodel_type"=>"term",
        "vocabulary"=>"/vocabularies/1"
      }
    end
    #get subdivisions
    next unless !field[1].nil? && (i > 2) && (i > 2)

    terms << {
      "term"=>field[1],
      "term_type"=>field[0],
      "jsonmodel_type"=>"term",
      "vocabulary"=>"/vocabularies/1"
    }
  end
  #get the record
  subject = @client.get(uri).parsed
  #replace the terms array
  subject['terms'] = terms
  #add a file history note
  add_maintenance_history(subject, "Subjects remediation: parse subfields")
  #post
  post = @client.post(uri, subject.to_json)
  puts post.body
end
puts Time.now
