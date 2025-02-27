require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative 'helper_methods.rb'

@client = aspace_login
out = "orphaned_dos.csv"
repos_all = (3..12).to_a
puts Time.now

dos = repos_all.map do |repo|
  get_all_digital_object_records_for_a_repository(repo)
end
dos = dos.flatten!

select_dos =
  dos.select do |dobject|
    next if dobject.nil?

    dobject['collection'].empty?
  end

CSV.open(out, "w",
    :write_headers => true,
    :headers => ["do_uri", "do_id", "collection_uri", "title", "linked_from"]) do |row|
    select_dos.map do |dobject|
        puts "#{dobject['uri']}, #{dobject['digital_object_id']}, #{dobject.dig('collection', 0, 'ref') || ''}, #{dobject['title']}, #{dobject.dig('linked_instances', 0, 'ref') || ''}"
        row << [dobject['uri'], (dobject['digital_object_id']), dobject.dig('collection', 0, 'ref') || '', dobject['title'], dobject.dig('linked_instances', 0, 'ref') || '']
    end
end

puts Time.now
