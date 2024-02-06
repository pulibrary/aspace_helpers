require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_login
puts Time.now

subject_to_delete = ""
agent_to_delete = ""
csv = CSV.parse(File.read("input.csv"), :headers => true)
record_uris = []
term1 = ""
term1type = ""
term1 = ""
term1type = ""
agent_ref = "" #/corporate_entities/1942 (Princeton University)

#1. delete subject and agent record as appropriate
@client.delete(subject_to_delete)
#2. for each descriptive object:
record_uris.each do |record_uri|
    record = @client.get(record_uri).parsed
    uri = record['uri']
    # link to agent and apply subject role and terms
    agent = {
        "ref" => ref
        "role"=>"subject", 
        "terms"=>[
         {
            "term"=>term1, 
            "term_type"=>term1type, 
            "jsonmodel_type"=>"term"
        },
        {
            "term"=>term2, 
            "term_type"=>term2type, 
            "jsonmodel_type"=>"term"
        }
    ]
    }
    # link to agent record
    record['linked_agends'] << agent
end

# {"role"=>"subject", 
#     "terms"=>[
#         {
#         "id"=>126, 
#         "lock_version"=>0, 
#         "json_schema_version"=>1, 
#         "vocab_id"=>1, 
#         "term"=>"Students", 
#         "term_type_id"=>1275, 
#         "created_by"=>"admin", 
#         "last_modified_by"=>"admin", 
#         "create_time"=>"2016-06-27T14:39:43Z", 
#         "system_mtime"=>"2016-06-27T14:39:43Z", 
#         "user_mtime"=>"2016-06-27T14:39:43Z", 
#         "x_foreign_key_x"=>489715, 
#         "term_type"=>"topical", 
#         "jsonmodel_type"=>"term", 
#         "uri"=>"/terms/126", 
#         "vocabulary"=>"/vocabularies/1"
#         }, 
#         {
#         "id"=>17868, 
#         "lock_version"=>0, 
#         "json_schema_version"=>1, 
#         "vocab_id"=>1, 
#         "term"=>"20th century", 
#         "term_type_id"=>1274, 
#         "created_by"=>"kbolding", 
#         "last_modified_by"=>"kbolding", 
#         "create_time"=>"2021-02-10T19:32:00Z", 
#         "system_mtime"=>"2021-02-10T19:32:00Z", 
#         "user_mtime"=>"2021-02-10T19:32:00Z", 
#         "x_foreign_key_x"=>489715, 
#         "term_type"=>"temporal", 
#         "jsonmodel_type"=>"term", 
#         "uri"=>"/terms/17868", 
#         "vocabulary"=>"/vocabularies/1"
#         }
#     ]
# , "ref"=>"/agents/corporate_entities/1942"}