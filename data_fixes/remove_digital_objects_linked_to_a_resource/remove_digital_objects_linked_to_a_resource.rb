require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative 'helper_methods.rb'


@client = aspace_staging_login

morrison = @client.get("/repositories/5/resources/4016/ordered_records").parsed
#greedy + matches second 's' as intended
ids = morrison['uris'].map {|uri| uri['ref'].gsub!(/^.+s\//, "") unless uri['level'] == 'collection'}
aos =
  ids.each do |id|
    unless id.nil?
    ao = get_single_archival_object_by_id(5, id, ['digital_object'])
    daos = ao['instances'].select { |instance| instance['instance_type'] == 'digital_object'}
    to_delete = daos.select do |dao|
      file_uri = dao['digital_object']['_resolved']['file_versions'][0]['file_uri']
      puts "#{dao['digital_object']['ref']}: #{file_uri}" if file_uri.match(/^pdf\//)
  end
end

  end
