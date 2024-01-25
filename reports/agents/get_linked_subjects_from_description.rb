require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_staging_login
puts Time.now
output_file = "linked_subjects.csv"

repositories = (12..12).to_a

CSV.open(output_file, "w",
    :write_headers => true,
    :headers => ["subject_uri", "subject_title", "subject_source", "subject_terms", "ao_uri"]) do |row|
    repositories.each do |repo|
        #get all ao id's for the repository
        all_ao_ids = @client.get("/repositories/#{repo}/archival_objects",
            query: {
              all_ids: true
            }).parsed

        #get all resolved ao's from id's and select those with linked agents
        resolve = ['subjects']
        all_aos = []
        count_processed_records = 0
        count_ids = all_ao_ids.count
        while count_processed_records < count_ids
            last_record = [count_processed_records+249, count_ids].min
            all_aos << @client.get("/repositories/#{repo}/archival_objects",
                    query: {
                      id_set: all_ao_ids[count_processed_records..last_record],
                      resolve: resolve
                    }).parsed
            count_processed_records = last_record
        end

        all_aos = all_aos.flatten.select do |ao|
            next if ao['subjects'].nil?

            ao['subjects'].empty? == false
        end
        puts all_aos

        # "subjects"=>[{
            # "ref"=>"/subjects/11975", 
            # "_resolved"=>{
            #     "lock_version"=>12, 
            #     "title"=>"Diplomatic documents -- China -- 19th century.", 
            #     "created_by"=>"admin", 
            #     "last_modified_by"=>"admin", 
            #     "create_time"=>"2021-01-24T01:51:24Z", 
            #     "system_mtime"=>"2024-01-25T13:18:47Z", 
            #     "user_mtime"=>"2021-01-24T01:51:24Z", 
            #     "is_slug_auto"=>true, 
            #     "source"=>"aat", 
            #     "jsonmodel_type"=>"subject", 
            #     "external_ids"=>[], 
            #     "publish"=>true, 
            #     "used_within_repositories"=>[], 
            #     "used_within_published_repositories"=>[], 
            #     "terms"=>[
            #         {"lock_version"=>0, 
            #         "term"=>"Diplomatic documents -- China -- 19th century.", 
            #         "created_by"=>"admin", "last_modified_by"=>"admin", 
            #         "create_time"=>"2021-01-24T01:51:24Z", 
            #         "system_mtime"=>"2021-01-24T01:51:24Z", 
            #         "user_mtime"=>"2021-01-24T01:51:24Z", 
            #         "term_type"=>"genre_form", 
            #         "jsonmodel_type"=>"term", 
            #         "uri"=>"/terms/11165", 
            #         "vocabulary"=>"/vocabularies/1"}
            #         ], 
            #     "external_documents"=>[], 
            #     "metadata_rights_declarations"=>[], 
            #     "uri"=>"/subjects/11975", 
            #     "vocabulary"=>"/vocabularies/1", 
            #     "is_linked_to_published_record"=>true}}]

        # #construct CSV row for ao's
        all_aos.map do |ao|
            ao['subjects'].each do |subject|
                row << [subject['ref'], subject['_resolved']['title'], subject['_resolved']['source'] || '', subject['_resolved']['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';'), ao['uri']]
                puts "#{subject['ref']}, #{subject['_resolved']['title']}, #{subject['_resolved']['source'] || ''}, #{subject['_resolved']['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';')}, ao['uri']"
            end
        end

        # #get all resources for the repository
        # all_resource_ids = @client.get("/repositories/#{repo}/resources",
        #     query: {
        #       all_ids: true
        #     }).parsed

        # all_resources = []
        # count_processed_records = 0
        # count_ids = all_resource_ids.count
        # while count_processed_records < count_ids
        #     last_record = [count_processed_records+249, count_ids].min
        #     all_resources << @client.get("/repositories/#{repo}/resources",
        #             query: {
        #               id_set: all_resource_ids[count_processed_records..last_record]
        #             }).parsed
        #     count_processed_records = last_record
        # end

        # # #get all resolved resources from id's and select those with linked agents
        # all_resources = all_resources.flatten.select do |resource|
        #     next if resource['linked_agents'].nil?

        #     resource['linked_agents'].empty? == false
        # end

        # # #construct CSV row for resources
        # all_resources.map do |resource|
        #     resource['linked_agents'].each do |linked_agent|
        #         row << [linked_agent['ref'], linked_agent['role'], linked_agent['relator'], linked_agent['terms'], resource['uri']]
        #         puts "#{linked_agent['ref']}, #{linked_agent['role']}, #{linked_agent['relator']}, #{linked_agent['terms']}, #{resource['uri']}"
        #     end
        # end
    end
end

puts Time.now
