require 'archivesspace/client'
require 'json'
require_relative 'helper_methods.rb'

aspace_staging_login()

#note has an array for value; rights_restriction is a hash of hashes; local_access_restriction_type has an array for value
# "notes"=>[{
#   "rights_restriction"=>{"local_access_restriction_type"=>[]},
#   }]

file = File.new('out.txt', 'a')
records = File.new('records.txt', 'a')

#records_all = get_all_records_for_repo_endpoint(4, 'archival_objects')
#repos_all = (3..12).to_a
repos_all = [7]
repos_all.each do |repo|
  endpoint_name = 'archival_objects'
  records_all = get_all_records_for_repo_endpoint(repo.to_s, endpoint_name)
  #File.write(records, records_all.to_s, mode: 'a')

  selected_records =
     records_all.select  do |record|
       with_restriction = record['restrictions_apply'] == true
       #without_restriction_type = record['notes'][0]['rights_restriction'].map {|k, v| v.empty?}
       without_restriction_type = if record.dig('notes', 0, 'rights_restriction', 'local_access_restriction_type')
         record['notes'][0]['rights_restriction']['local_access_restriction_type'].empty?
       end
   end

  File.write(file, selected_records.to_s, mode: 'a')
  #puts selected_records[0..2]
end
