require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

@client = aspace_login
out = "dos_new.csv"
puts Time.now

dos = get_all_digital_object_records_for_a_repository(3, ['linked_instances'])

select_dos = []
dos.select do |dobject|
  select_dos << dobject if ["/repositories/3/resources/1860", "/repositories/3/resources/1861"].include? dobject.dig('collection', 0, 'ref')
end

puts select_dos[0..9]

CSV.open(out, "w",
    :write_headers => true,
    :headers => ["do_uri", "do_id", "collection_uri", "title", "linked_from"]) do |row|
    select_dos.map do |dobject|
        puts "#{dobject['uri']}, #{dobject['digital_object_id']}, #{dobject.dig('collection', 0, 'ref') || ''}, #{dobject['title']}, #{dobject.dig('linked_instances', 0, 'ref') || ''}, #{dobject.dig('linked_instances', 0, '_resolved', 'ref_id') || ''}"
        row << [dobject['uri'], (dobject['digital_object_id']), dobject.dig('collection', 0, 'ref') || '', dobject['title'], dobject.dig('linked_instances', 0, 'ref') || '', dobject.dig('linked_instances', 0, '_resolved', 'ref_id')]
    end
end

puts Time.now
