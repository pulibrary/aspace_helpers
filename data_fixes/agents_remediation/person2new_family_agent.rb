require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

#_____________________________
#
# WORKFLOW FOR REPLACING A PERSON RECORD WITH A NEW FAMILY RECORD
# 1. gather distinct person records to delete
# 2. construct new family record from false person record
# 3. post new family record and map new to old uri in a hash
# 4. link and post descriptive record
# 5. delete false person record
# ____________________________

aspace_staging_login
puts Time.now

csv = CSV.parse(File.read("input.csv"), :headers => true)

# gather records to delete
@deletes = []
@old2new_uri = {}
csv.each do |row|
    @deletes << row['heading_uri']
end

@deletes = @deletes.uniq

@deletes.each do |delete_uri|
    # get the full superseded person agent record
    old_record = @client.get(delete_uri).parsed
    #construct a new family agent record
    new_record = {
      "publish"=>true,
        "jsonmodel_type"=>"agent_family",
        "agent_contacts"=>old_record['agent_contacts'],
        "agent_record_controls"=>[{
          "maintenance_agency"=>"NjP",
            "agency_name"=>"Princeton University Library",
            "created_by"=>"heberlei",
            "maintenance_status"=>"new",
            "jsonmodel_type"=>"agent_record_control"
        }],
        "agent_alternate_sets"=>old_record['agent_alternate_sets'],
        "agent_conventions_declarations"=>old_record['agent_conventions_declarations'],
        "agent_other_agency_codes"=>old_record['agent_other_agency_codes'],
        "agent_maintenance_histories"=>old_record['agent_maintenance_histories'],
        "agent_record_identifiers"=>old_record['agent_record_identifiers'],
        "agent_identifiers"=>old_record['agent_identifiers'],
        "agent_sources"=>old_record['agent_sources'],
        "agent_places"=>old_record['agent_places'],
        "agent_occupations"=>old_record['agent_occupations'],
        "agent_functions"=>old_record['agent_functions'],
        "agent_topics"=>old_record['agent_topics'],
        "agent_resources"=>old_record['agent_resources'],
        "linked_agent_roles"=>old_record['linked_agent_roles'],
        "external_documents"=>old_record['external_documents'],
        "notes"=>old_record['notes'],
        "used_within_repositories"=>old_record['used_within_repositories'],
        "used_within_published_repositories"=>old_record['used_within_published_repositories'],
        "dates_of_existence"=>old_record['dates_of_existence'],
        "used_languages"=>old_record['used_languages'],
        "metadata_rights_declarations"=>old_record['metadata_rights_declarations'],
        "names"=>old_record['names'].map do |name|
            {
              "family_name"=>name['primary_name'],
            "sort_name"=>name['sort_name'],
            "sort_name_auto_generate"=>name['sort_name_auto_generate'],
            "authorized"=>name['authorized'],
            "is_display_name"=>name['is_display_name'],
            "source"=>name['source'],
            "rules"=>name['rules'],
            "name_order"=>name['name_order'],
            "jsonmodel_type"=>"name_family",
            "use_dates"=>name['use_dates'],
            "parallel_names"=>name['parallel_names']
            }
            end,
        "related_agents"=>old_record['related_agents'],
        "agent_type"=>"agent_family",
        "is_linked_to_published_record"=>old_record['is_linked_to_published_record'],
        "display_name"=>{
          "primary_name"=>old_record['display_name']['primary_name'],
            "sort_name"=>old_record['display_name']['sort_name'],
            "sort_name_auto_generate"=>old_record['display_name']['sort_name_auto_generate'],
            "authorized"=>old_record['display_name']['authorized'],
            "is_display_name"=>old_record['display_name']['is_display_name'],
            "source"=>old_record['display_name']['source'],
            "rules"=>old_record['display_name']['rules'],
            "name_order"=>old_record['display_name']['name_order'],
            "jsonmodel_type"=>"name_family",
            "use_dates"=>old_record['display_name']['use_dates'],
            "parallel_names"=>old_record['display_name']['parallel_names']
        },
        "title"=>old_record['title']
    }

    #post the new record and store its uri in a variable
    create_new_record = @client.post("/agents/families", new_record.to_json)
    puts create_new_record.body
    api_response = JSON.parse(create_new_record.body).to_hash
    new_record_uri = api_response['uri']
    @old2new_uri[delete_uri] = new_record_uri
end
csv.each do |row|
    # get the descriptive record
    descriptive_record = @client.get(row['record_uri']).parsed

    # link to the new agent record
    descriptive_record['linked_agents'] << {"ref"=>@old2new_uri[row['heading_uri']], "role"=>row['role'], "relator"=>row['relator']}

    # add a revision statement
    if row['record_uri'] =~ /resources/
        add_resource_revision_statement(descriptive_record, "Subject remediation: replaced person with agent record.")
    end
    post = @client.post(row['record_uri'], descriptive_record.to_json)
    puts post.body
end

#delete false subject headings
@deletes.each do |uri_to_delete|
    delete = @client.delete(uri_to_delete)
    puts delete.body
end

puts Time.now
