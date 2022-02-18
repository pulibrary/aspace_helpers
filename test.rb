require 'archivesspace/client'
require 'json'
require 'csv'
require_relative 'helper_methods.rb'

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

record = get_single_archival_object_by_id(3, 414407)
puts record

puts "Process ended #{Time.now}."
