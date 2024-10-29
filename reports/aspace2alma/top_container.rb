require 'nokogiri'
require 'active_support/all'
require 'archivesspace/client'

class TopContainer
  # attr_reader :resource_uri, :aspace_client

  # def initialize(resource_uri, aspace_client, _file, _log_out, _remote_file)
  #   @resource_uri = resource_uri
  #   @aspace_client = aspace_client
  # end

  def initialize(container_doc); end

  def resource_uri
    #container['collection_uri_u_sstr']
  end
end
