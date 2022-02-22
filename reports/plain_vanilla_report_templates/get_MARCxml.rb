require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_staging_login()

marc_record = @client.get("/repositories/4/resources/marc21/2065.xml")
doc = Nokogiri::XML(marc_record.body)
#
# Search for nodes by xpath
puts doc.xpath('//marc:datafield[@tag="520"]')
