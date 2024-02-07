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
agent_ref = "/agents/corporate_entities/1942" #/corporate_entities/1942 (Princeton University)

#1. gather subjects and agents to delete
@deletes = []
#2. for each row:
csv.each do |row|
    @deletes << row['heading_uri']
    # get the descriptive record
    record = @client.get(row['record_uri']).parsed
    # link to agent and apply subject role and terms
    agent = {
        "role"=>"subject",
        "terms"=>[
            if row['term1'].blank? == false
            {
                "term"=>row['term1'], 
                "term_type"=>row['term1type'], 
                "jsonmodel_type"=>"term",
                "vocabulary"=>"/vocabularies/1"
            }
            end,
            if row['term2'].blank? == false
            {
                "term"=>row['term2'], 
                "term_type"=>row['term2type'], 
                "jsonmodel_type"=>"term",
                "vocabulary"=>"/vocabularies/1"
            }
            end,
            if row['term3'].blank? == false
            {
                "term"=>row['term3'], 
                "term_type"=>row['term3type'], 
                "jsonmodel_type"=>"term",
                "vocabulary"=>"/vocabularies/1"
            }
            end
        ],
    "ref" => agent_ref
    }
    #puts agent
    unless record['linked_agents'].nil?
        # link to agent record
        record['linked_agents'] << agent 
        post = @client.post(row['record_uri'], record.to_json)
        puts post.body
    end 
end
#delete false subject headings
@deletes = @deletes.uniq
@deletes.each do |uri_to_delete|
    @client.delete(uri_to_delete)
    puts delete.body
end

puts Time.now

