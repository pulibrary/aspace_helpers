require 'archivesspace/client'
require 'active_support/all'
require 'csv'
require_relative '../../helper_methods.rb'


aspace_login
puts Time.now
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/langmaterial/languages_to_fix.csv"), :headers => true)

csv.each do |row|
  uri = row['uri']
  record = @client.get(uri).parsed
  lang_to_fix = record['lang_materials'].select { |langmaterial| langmaterial['notes'].empty? == false}
  lang_to_fix.each do |langmaterial|
    language_code = langmaterial['notes'][0]['content'][0].gsub(/<language langcode=\"/, "").gsub(/\"\/>/, "")
    language = { 
      "language" => "#{language_code}", 
      "jsonmodel_type" => "language_and_script"
    }
    langmaterial['notes'] = []
    langmaterial["language_and_script"] = language
  end
  post = @client.post(uri, record)
  puts post.body
end
puts Time.now

