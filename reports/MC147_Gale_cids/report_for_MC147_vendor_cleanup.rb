require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

eadid = "MC147"
resource_id = "1650"
repo = 3
output_file = "#{eadid}.csv"
ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed
#/repositories/:repo_id/resources/:id/ordered_records
#get_all_archival_objects_for_resource(4, 4185, ['top_containers'])

  CSV.open(output_file, "a",
    :write_headers=> true,
    :headers => ["uri", "ref_id", "title", "first_date"]) do |row|
    ao_tree['uris'].each do |ao_ref|
      ao_uri = []
      ao_uri << ao_ref['ref'] unless ao_ref.dig('level') == 'collection'
      #puts ao_uri

    ao_uri.each do |uri|
      #puts uri.class
      get_ao = @client.get(uri).parsed
        row << [get_ao['uri'], get_ao['ref_id'], get_ao['title'], get_ao['dates'][0]['expression']]
        puts "#{get_ao['uri']}, #{get_ao['ref_id']}, #{get_ao['title']}, #{get_ao['dates'][0]['expression']}"
    end #uri.each
        rescue Exception => msg
        end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
      end #csv
    end #tree.each

end_time = "Process ended: #{Time.now}"
puts end_time
