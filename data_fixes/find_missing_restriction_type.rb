require 'archivesspace/client'
require 'json'
require_relative '../helper_methods.rb'

aspace_login()

#records_all = get_all_records_for_repo_endpoint(4, 'archival_objects')
repos_all = (3..12).to_a
#repos_all = [7]

repos_all.each do |repo|
  filename = "find_missing_restriction_type_" + repo.to_s + ".csv"
  endpoint_name = 'archival_objects'
  records_all = get_all_records_for_repo_endpoint(repo.to_s, endpoint_name)
  #File.write(records, records_all.to_s, mode: 'a')
#get records with restrictions_apply set to true yet missing restriction type
  selected_records =
     records_all.select  do |record|
       with_restriction = record['restrictions_apply'] == true &&
       without_restriction_type =
         if record.dig('notes', 0, 'rights_restriction', 'local_access_restriction_type')
           record['notes'][0]['rights_restriction']['local_access_restriction_type'].empty?
         end
   end

  #File.write(file, selected_records.to_s, mode: 'a')
#write uri and ref_id (i.e. former cid) to csv
  CSV.open(filename, "wb",
      :write_headers=> true,
      :headers => ["uri", "ref_id"]) do |row|
          selected_records.each do |record|
            uri = record['uri']
            refid = record['ref_id']
            row << [uri, refid]
          end
        end
end
