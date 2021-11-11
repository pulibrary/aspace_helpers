require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time


filename = "get_do_filenames.csv"
#repos_all = [9]
repos_all = (3..12).to_a

CSV.open(filename, "wb",
  :write_headers => true,
  :headers => ["file_uri", "uri"]) do |row|

# #declare input file with uri and restriction value
# csv = CSV.parse(File.read("/Users/heberleinr/Documents/aspace_helpers/data_fixes/remove_digital_objects/input_daos_mets.xlsx"), :headers => true)
# log = "data_fixes/unnest_boxes/nested_boxes_log.txt"

# digo = get_single_do_by_id(5, 54559, resolve = [])
# digo['file_versions'].each do |version|
# puts version['file_uri']
# puts digo['uri']
# end
  repos_all.each do |repo|
    unless repo.nil?
      dos = get_all_records_for_repo_endpoint(repo, "digital_objects")
      unless dos.nil?
        dos.each do |digo|
          digo['file_versions'].each do |version|
            row << [version['file_uri'], digo['uri']]
          puts "#{version['file_uri']} #{digo['uri']}"
          end
        end
      end
    end
  end
end

puts "Process ended: #{Time.now}"
