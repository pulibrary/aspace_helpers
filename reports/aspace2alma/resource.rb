require 'nokogiri'
require 'archivesspace/client'

# A class to manipulate records from ASpace MarcXML
class Resource
  attr_reader :resource_uri, :aspace_client

  def initialize(resource_uri, aspace_client, _file, _log_out, _remote_file)
    @resource_uri = resource_uri
    @aspace_client = aspace_client
  end

  def marc_uri
    "#{resource_uri.gsub('resources', 'resources/marc21')}.xml"
  end

  def marc_xml
   Nokogiri::XML(aspace_client.get(marc_uri).body)
  end
end
