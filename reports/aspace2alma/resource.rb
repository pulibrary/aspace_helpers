# A class to manipulate records from ASpace MarcXML
class Resource
  attr_reader :resource_uri

  def initialize(resource_uri, _file, _log_out, _remote_file)
    @resource_uri = resource_uri
  end

  def marc_uri
    "#{resource_uri.gsub('resources', 'resources/marc21')}.xml"
  end
end
