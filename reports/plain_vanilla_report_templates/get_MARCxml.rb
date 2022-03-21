require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_login(@production)

puts Time.now
filename = "out.xml"

resources = get_all_resource_uris_for_institution

file =  File.open(filename, "w")
file << '<collection xmlns="http://www.loc.gov/MARC21/slim" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">'

resources.each do |resource|
  uri = resource.gsub!("resources", "resources/marc21") + ".xml"
  marc_record = @client.get(uri)
  doc = Nokogiri::XML(marc_record.body)

  #recursively remove truly empty elements (blank text and attributes)
  #use node.attributes.blank? for all attributes
  def remove_empty_elements(node)
    node.children.map { |child| remove_empty_elements(child) }
    node.remove if node.content.blank? && (
    (node.attribute('@ind1').blank? && node.attribute('@ind2').blank?) ||
    node.attribute('@code').blank?)
  end

  #remove linebreaks from notes
  def remove_linebreaks(node)
    node.xpath("//marc:subfield/text()").map { |text| text.content = text.content.gsub(/[\n\r]+/," ") }
  end

  # set up variables (these may return a sequence)
  ##################
  tag008 = doc.at_xpath('//marc:controlfield[@tag="008"]')
  tags040 = doc.xpath('//marc:datafield[@tag="040"]')
  tag041 = doc.at_xpath('//marc:datafield[@tag="041"]')
  tag099_a = doc.at_xpath('//marc:datafield[@tag="099"]/marc:subfield[@code="a"]')
  tags520 = doc.xpath('//marc:datafield[@tag="520"]')
  tags544 = doc.xpath('//marc:datafield[@tag="544"]')
  tags852 = doc.xpath('//marc:datafield[@tag="852"]')
  tag856 = doc.at_xpath('//marc:datafield[@tag="856"]')
  tags500_a = doc.xpath('//marc:datafield[@tag="500"]/marc:subfield[@code="a"]')
  tags6xx = doc.xpath('//marc:datafield[@tag = "700" or @tag = "650" or
    @tag = "651" or @tag = "610" or @tag = "630" or @tag = "648" or
    @tag = "655" or @tag = "656" or @tag = "657"]')
  subfields = doc.xpath('//marc:subfield')

  #do stuff
  ##################

  #addresses github #128
  remove_empty_elements(doc)

  #addresses github #159
  remove_linebreaks(doc)

  #addresses github #129
  tag008.previous=("<controlfield tag='001'>#{tag099_a.content}</controlfield")

  #addresses github #130
  tag008.previous=("<controlfield tag='003'>PULFA</controlfield")

  #addresses github #144
  #swap quotes so interpolation is possible
  tag008.next=("<datafield ind1=' ' ind2=' ' tag='035'>
    <subfield code='a'>(PULFA)#{tag099_a.content}</subfield>
    </controlfield")

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
  tag041.next=("<datafield ind1=' ' ind2=' ' tag='046'>
        <subfield code='a'>i</subfield>
        <subfield code='c'>#{tag008.content[7..10]}</subfield>
        <subfield code='e'>#{tag008.content[11..14]}</subfield>
      </datafield>")

  #addresses github #168
  tags520 = tags520.map.with_index { |tag520, index| tag520.remove if index > 0}

  #addresses github #133
  #NB node.children.before inserts new node as first of node's children; default for add_child is last
  tags544.each do |tag544|
    tag544.children.before('<subfield code="a">')
  end

  #addresses github #143
  #adapted from Mark's implementation of Don's logic
  tags6xx.each do |tag6xx|
    subfield_a = tag6xx.at_xpath('marc:subfield[@code="a"]')
    segments = subfield_a.content.split('--')
    segments.each { |segment| segment.strip! }
    subfield_a_text = segments[0]
    new_subfield_a = subfield_a.replace("<subfield code='a'>#{subfield_a_text}</subfield")

    segments[1..-1].each do |segment|
      code = segment =~ /^[0-9]{2}/ ? 'y' : 'x'
      #new_subfield_a is a node set of one
      new_subfield_a[0].next=("<subfield code='#{code}'>#{segment}</subfield>")
    end
    #add punctuation to the last subfield except $2
    if tag6xx.children[-1].attribute('code') == '2'
      tag6xx.children[-2].content << '.' unless ['?', '-', '.'].include?(tag6xx.children[-2].content[-1])
    else
      tag6xx.children[-1].content << '.' unless ['?', '-', '.'].include?(tag6xx.children[-1].content[-1])
    end
  end

  #addresses github #132
  tags852.remove

  #addresses github 147
  unless tags500_a.nil?
    tags500_a.select do |tag500_a|
      #the exporter adds preceding text and punctuation for each physloc.
      #hardcode location codes because textual physlocs are patterned the same
      if tag500_a.content.match(/Location of resource: (anxb|ea|ex|flm|flmp|gax|hsvc|hsvm|mss|mudd|prnc|rarebooks|rcpph|rcppf|rcppl|rcpxc|rcpxg|rcpxm|rcpxr|st|thx|wa|review|oo|sc|sls)/)
        #strip text preceding and following code
        location_notes = tag500_a.content.gsub(/.*:\s(.+)[.]/, "\\1")
        location_notes.split.each do |tag|
          #add as the last datafield
          doc.xpath('//marc:datafield').last.next=
          ("<datafield ind1=' ' ind2=' ' tag='982'><subfield code='c'>#{tag}</subfield></datafield>")
          end unless location_notes.nil?
      end
    end
  end

  #append record to file
  file << doc.at_xpath('//marc:record')
  file.flush
end
file << '</collection>'
file.close
puts Time.now
