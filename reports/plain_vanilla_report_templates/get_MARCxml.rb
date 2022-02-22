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
  node.remove if node.content.blank? && (
  (node.attribute('@ind1').blank? && node.attribute('@ind2').blank?) ||
  node.attribute('code').blank?)
end

# set up variables
##################
tags852 = doc.xpath('//marc:datafield[@tag="852"]')

#do stuff
##################

#addresses github #128
remove_empty_elements(doc)

#addresses github #132
tags852.remove
# tags49.each do |tag49|
#   tag49.remove if tag49.content.empty?
# end
#tags520[0].content = "Snap, Crackle & Pop"

puts doc
