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

# set up variables (these may return a sequence)
##################
tag008 = doc.at_xpath('//marc:controlfield[@tag="008"]')
tags040 = doc.xpath('//marc:datafield[@tag="040"]')
tag041 = doc.at_xpath('//marc:datafield[@tag="041"]')
tags544 = doc.xpath('//marc:datafield[@tag="544"]')
tags852 = doc.xpath('//marc:datafield[@tag="852"]')

#do stuff
##################

#addresses github #128
remove_empty_elements(doc)

#addresses github #131
tags040.each do |tag040|
  tag040.replace('<datafield ind1=" " ind2=" " tag="040">
      <subfield code="a">NjP</subfield>
      <subfield code="b">eng</subfield>
      <subfield code="e">dacs</subfield>
      <subfield code="c">NjP</subfield>
    </datafield>')
end

#addresses github #134
#swap quotes so interpolation is possible
tag041.next=("<datafield ind1=' ' ind2=' ' tag='046'>
      <subfield code='a'>i</subfield>
      <subfield code='c'>#{tag008.content[7..10]}</subfield>
      <subfield code='e'>#{tag008.content[11..14]}</subfield>
    </datafield>")

#addresses github #133
#NB node.children.before inserts new node as first of node's children; default for add_child is last
tags544.each do |tag544|
  tag544.children.before('<subfield code="a">')
end

#addresses github #132
tags852.remove


# tags49.each do |tag49|
#   tag49.remove if tag49.content.empty?
# end
#tags520[0].content = "Snap, Crackle & Pop"

puts doc
