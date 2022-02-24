require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_staging_login()

temp_file = "temp.xml"
filename = "out.xml"

resources = get_all_resource_uris_for_institution
#remove this filter when testing is finished; I'm just testing with two records here

file =  File.open(filename, "w")
file << '<collection xmlns="http://www.loc.gov/MARC21/slim" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">'

resources[0..1].each do |resource|
  uri = resource.gsub!("resources", "resources/marc21") + ".xml"
  marc_record = @client.get(uri)
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
  tag099_a = doc.at_xpath('//marc:datafield[@tag="099"]/marc:subfield[@code="a"]')
  tags544 = doc.xpath('//marc:datafield[@tag="544"]')
  tags852 = doc.xpath('//marc:datafield[@tag="852"]')

  #do stuff
  ##################

  #addresses github #128
  remove_empty_elements(doc)

  #addresses github #129
  tag008.previous=("<controlfield tag='001'>#{tag099_a.content}</controlfield")

  #addresses github #130
  tag008.previous=("<controlfield tag='003'>PULFA</controlfield")

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

  #append record to file
  file << doc.at_xpath('//marc:record')
  file.flush
end
file << '</collection>'
file.close
