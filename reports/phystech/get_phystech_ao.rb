require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

@client = aspace_login
start_time = "Process started: #{Time.now}"
puts start_time

repos = [3, 4, 5]

repos.each do |repo|
  resource_ids = add_ids_to_array(repo, 'resources')
  puts "Repo #{repo}: #{resource_ids.count} resources to walk"
  resource_ids.each do |resource_id|
    ao_refs = @client.get("repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed['uris']
    records_by_uri = batch_get_records_by_uris(ao_refs.map { |ao_ref| ao_ref['ref'] })
    records_by_uri.each do |uri, record|
      eadid_or_cid = record['ead_id'] || record['ref_id']
      phystechs = record['notes'].select {|note| note['type']=='phystech'}
      phystechs.each do |phystech|
        puts "#{eadid_or_cid}, #{uri}, #{phystech}"
      end
    end
  end
end

puts "Process ended #{Time.now}."
