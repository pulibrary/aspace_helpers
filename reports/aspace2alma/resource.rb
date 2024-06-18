# A class to manipulate records from ASpace MarcXML
class Resource
  attr_reader :resource_uri

  def initialize(resource_uri, file, log_out, remote_file)
    @resource_uri = resource_uri
  end

  def marc_uri
    "#{resource_uri.gsub('resources', 'resources/marc21')}.xml"
  end
end
