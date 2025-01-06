require 'archivesspace/client'
require_relative 'ASpace_helpers'

aspace_login()

resources_all = get_all_resource_records()
resources_all_parsed = resources_all.map(&:parsed)
resources_all_parsed = resources_all_parsed.flatten!
#debug:
#puts "total objects in array: #{resources_all.count}"
#puts "total records in array: #{resources_all_parsed.count}"
#puts resources_all_parsed[0]

resources_to_fix = []
resources_to_fix = resources_all_parsed.select do |record|
  ref = record['linked_agents'].select { |agent| agent['ref'] == '/agents/corporate_entities/2028' }
  relator = record['linked_agents'].select { |agent| agent['relator'] == 'col' }
  !ref.empty? && !relator.empty?
end
puts resources_to_fix
