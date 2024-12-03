require 'active_support/all'
require 'archivesspace/client'

#A class to manipulate an ArchivesSpace top_container JSON record
class TopContainer
  attr_reader :container_doc

  # def initialize(resource_uri, aspace_client, _file, _log_out, _remote_file)
  #   @resource_uri = resource_uri
  #   @aspace_client = aspace_client
  # end

  def initialize(container_doc)
    #instance variable = the thing that's passed in
    @container_doc = JSON.parse(container_doc['json'])
  end

  def location_code
    container_doc.dig('container_locations', 0, '_resolved', 'classification')
  end

  def at_recap?
    /^(sca)?rcp\p{L}+/.match?(location_code)
  end

  def barcode?
    container_doc['barcode'].present?
  end

  def not_already_in_alma?(set)
    !set.include?(container_doc['barcode'])
  end

  def valid?(set)
    at_recap? &&
      barcode? &&
      not_already_in_alma?(set)
  end
end
