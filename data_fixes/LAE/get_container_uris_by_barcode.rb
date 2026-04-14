require 'active_support/all'
#require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

puts "Process started: #{Time.now}"
csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/done_helper_files/LAE049-050_mf_containers.csv"), :headers => true)
csv.each do |row|
    barcode = row['Barcode'].to_s
    uri = @client.get("/repositories/8/find_by_id/top_containers", {query: {
                        barcode: [barcode]
                      }}).parsed
    puts uri['top_containers'][0]['ref']
end

# docs = top_container_uris = @client.get(
# 'repositories/8/top_containers/search',
# query: { q: 'location_uri_u_sstr:"/locations/23669"' }
# ).parsed['response']['docs']

# docs.each do |doc|
#   puts "#{doc['id']}, #{doc['barcode_u_icusort']}"
# end
