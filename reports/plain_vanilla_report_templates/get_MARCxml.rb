require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_staging_login()

marc_record = @client.get("/repositories/4/resources/marc21/2065.xml")
doc = Nokogiri::XML(marc_record.body)

#recursively remove truly empty elements (blank text and attributes)
#use node.attributes.blank? for all attributes
def remove_empty_elements(node)
  node.children.map { |child| remove_empty_elements(child) }
  node.remove if node.content.blank? && node.attribute('@ind1').blank? && node.attribute('@ind2').blank?
end

remove_empty_elements(doc)

# Search for nodes by xpath
tags49 = doc.xpath('//marc:datafield[@tag="049"]')
tags520 = doc.xpath('//marc:datafield[@tag="520"]')

# tags49.each do |tag49|
#   tag49.remove if tag49.content.empty?
# end
tags520[0].content = "Snap, Crackle & Pop"

puts doc
