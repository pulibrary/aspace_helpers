require 'archivesspace/client'
require 'active_support/all'
require 'csv'
require_relative '../../helper_methods.rb'

puts Time.now
output_file = "top_containers_of_type_not_box.csv"

aspace_login

top_containers = get_all_top_container_records_for_institution

not_boxes = top_containers.reject do |container|
    container['type'] = "box"
end

CSV.open(output_file, "w",
    :write_headers => true,
    :headers => ["uri", "eadid", "display_string", "type", "indicator"]) do |row|
    not_boxes.map do |container|
        puts "#{container['uri']}, #{container['collection'][0]['identifier'] unless container['collection'].empty?}, #{container['display_string']}, #{container['type'] || ''}, #{container['indicator'] || ''}"
        row << [container['uri'], (container['collection'][0]['identifier'] unless container['collection'].empty?), container['display_string'], container['type'] || '', container['indicator'] || '']
    end
end

puts Time.now
