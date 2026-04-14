require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

puts "Process started: #{Time.now}"

#input: edit csv, ao_uri, and instance_type

#link containers to ao
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/done_helper_files/LAE106_mf_containers.csv"), :headers => true)
csv.each do |row|
  container_uri = row['container_uri']
  ao_uri = "/repositories/8/archival_objects/1575919"
  record = @client.get(ao_uri).parsed
  record['instances'].append(
    {
      instance_type: "microform",
      jsonmodel_type: "instance",
      is_representative: false,
      sub_container: {
        jsonmodel_type: "sub_container",
        top_container: {ref: container_uri}
      }
    }
  )
    post = @client.post(ao_uri, record)
    puts post.body
end
