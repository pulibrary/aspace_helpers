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
        #define resolve parameter
        resolve = ['subjects']
        #get all ao id's for the repository
        all_ao_ids = @client.get("/repositories/#{repo}/archival_objects",
            query: {
              all_ids: true
            }).parsed

        #get all resolved ao's from id's and select those with linked agents
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

        # #construct CSV row for ao's
        all_aos.map do |ao|
            ao['subjects'].each do |subject|
                row << [subject['ref'], subject['_resolved']['title'], subject['_resolved']['source'] || '', subject['_resolved']['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';'), ao['uri']]
                puts "#{subject['ref']}, #{subject['_resolved']['title']}, #{subject['_resolved']['source'] || ''}, #{subject['_resolved']['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';')}, #{ao['uri']}"
            end
        end

        #get all resources for the repository
        all_resource_ids = @client.get("/repositories/#{repo}/resources",
            query: {
              all_ids: true
            }).parsed

        all_resources = []
        count_processed_records = 0
        count_ids = all_resource_ids.count
        while count_processed_records < count_ids
            last_record = [count_processed_records+249, count_ids].min
            all_resources << @client.get("/repositories/#{repo}/resources",
                    query: {
                      id_set: all_resource_ids[count_processed_records..last_record],
                      resolve: resolve
                    }).parsed
            count_processed_records = last_record
        end

        #get all resolved resources from id's and select those with linked agents
        all_resources = all_resources.flatten.select do |resource|
            next if resource['subjects'].nil?

            resource['subjects'].empty? == false
        end
        #construct CSV row for resources
        all_resources.map do |resource|
            resource['subjects'].each do |subject|
                row << [subject['ref'], subject['_resolved']['title'], subject['_resolved']['source'] || '', subject['_resolved']['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';'), resource['uri']]
                puts "#{subject['ref']}, #{subject['_resolved']['title']}, #{subject['_resolved']['source'] || ''}, #{subject['_resolved']['terms'].map {|term| term['term'] + " : " + term['term_type'] + " : " + term['vocabulary']}.join(';')}, #{resource['uri']}"
            end
        end
    end
end

puts Time.now
