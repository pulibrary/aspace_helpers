require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

csv = CSV.parse(File.read("cids.csv"), :headers => true)
out = "cids2uris.txt"
