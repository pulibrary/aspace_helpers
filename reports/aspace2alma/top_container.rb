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
    @container_doc = JSON.parse(container_doc)
  end
end
