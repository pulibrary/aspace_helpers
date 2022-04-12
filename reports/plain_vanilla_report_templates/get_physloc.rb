require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_login

records = get_all_resource_records_for_institution

records.each do |record|
  eadid = record['ead_id']
  uri = record['uri']
  physlocs = record['notes'].select {|note| note['type']=='physloc'}
  physlocs.each do |physloc|
    puts "#{eadid},#{uri},#{physloc['content'][0]}"
  end
end
