require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login()

filename = 'get_tcs.csv'
repos_all = (3..12).to_a

start_time = "Process started: #{Time.now}"
puts start_time

tcs = get_all_top_container_records_for_institution()

CSV.open(filename, "wb",
    :write_headers=> true,
    :headers => ["uri"]) do |row|
      tcs.each do |tc|
        row << tc
      end
    end

puts "Process ended: #{Time.now}"
