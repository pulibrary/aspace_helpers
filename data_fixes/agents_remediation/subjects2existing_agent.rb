require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

#_____________________________
#
# WORKFLOW FOR REPLACING A SUBJECT WITH AN EXISTING AGENT
# AND ADDING SUBDIVISIONS TO THE DESCRIPTIVE RECORD
# 1. delete subject record
# 2. get descriptive record formerly linking to the deleted subject
# 3. link existing agent to descriptive record
# 4. add subdivisions from deleted subject record
# 5. post descriptive record
# ____________________________

aspace_staging_login
puts Time.now

csv = CSV.parse(File.read("input.csv"), :headers => true)
term1 = "Alumni and alumnae"
term1type = "topical"
term2 = ""
term2type = ""
agent_ref = "/agents/corporate_entities/1942" #/corporate_entities/1942 (Princeton University)

#1. for each row:
#2. delete subject and agent record as appropriate
csv.each do |row|
    delete = @client.delete(row['heading_uri'])
    puts delete.body
    record = @client.get(row['record_uri']).parsed
    # link to agent and apply subject role and terms
    agent = {
        "role"=>"subject", 
        "terms"=>[
        if term1.blank? == false
            {
                "term"=>term1, 
                "term_type"=>term1type, 
                "jsonmodel_type"=>"term",
                "vocabulary"=>"/vocabularies/1"
            }
            if term2.blank? == false
                {
                    "term"=>term2, 
                    "term_type"=>term2type, 
                    "jsonmodel_type"=>"term",
                    "vocabulary"=>"/vocabularies/1"
                }
            end
        end
    ],
    "ref" => agent_ref
    }
    # link to agent record
    record['linked_agents'] << agent
    post = @client.post(row['record_uri'], record.to_json)
    puts post.body
end

puts Time.now

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