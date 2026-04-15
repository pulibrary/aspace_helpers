require 'archivesspace/client'
require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

puts "Process started: #{Time.now}"

#input: edit csv, ao_uri, and instance_type

#link containers to ao
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/dos.csv"), :headers => true)
csv.each do |row|
  do_uri = row['do_uri']
  resource_uri = row['uri']
  record = @client.get(resource_uri).parsed
  record['instances'].append(
    {
      "jsonmodel_type" => "instance",
      "instance_type" => "digital_object",
      "is_representative" => false,
      "digital_object" => {"ref" => do_uri}
    }
  )
    post = @client.post(resource_uri, record)
    puts post.body
end
