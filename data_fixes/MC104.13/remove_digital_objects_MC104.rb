require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../../helper_methods.rb'


@client = aspace_staging_login
log = "delete_dos_MC10413.txt"

start_time = "Process started: #{Time.now}"
puts start_time

resource = @client.get("/repositories/3/resources/1862/ordered_records").parsed
#greedy '+'' matches second 's' as intended
ids = resource['uris'].map {|uri| uri['ref'].gsub!(/^.+s\//, "") unless uri['level'] == 'collection'}
  ids.each do |id|
    unless id.nil?
    ao = get_single_archival_object_by_id(3, id, ['digital_object'])
    daos = ao['instances'].select { |instance| instance['instance_type'] == 'digital_object'}
    to_delete = daos.select do |dao|
      uri = dao['digital_object']['ref']
      file_uri = dao['digital_object']['_resolved']['file_versions'][0]['file_uri']
      puts "#{uri}: #{file_uri}" if file_uri.match(/^http:\/\/findingaids.princeton.edu\/cfr\/\?ead=/)
      if file_uri.match(/^http:\/\/findingaids.princeton.edu\/cfr\/\?ead=/)
        delete = @client.delete(uri)
        response = delete.body
        puts response
      end
      File.write(log, response, mode: 'a')
      rescue Exception => msg
      puts "Processing failed at #{Time.now} with error '#{msg.class}: #{msg.message}'"
       end
    end
  end
  puts "Process ended: #{Time.now}"
