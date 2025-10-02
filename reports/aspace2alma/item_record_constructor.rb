require 'csv'
require 'json'
require_relative 'top_container'

Params = Struct.new(:doc, :tag099_a, :log_out, :alma_barcodes_set)
# Module with utility functions for item record processing.
module ItemRecordUtils
  def self.extract_repository_id(resource)
    resource.gsub(ItemRecordConstructor::REPO_PATH_REGEX, '\2')
  end

  def self.sort_containers_by_indicator(containers)
    containers.sort_by do |container|
      JSON.parse(container['json'])['indicator'].scan(/\d+/).first.to_i
    end
  end

  def self.log_container_creation(log_out, json)
    log_out.puts "Created record for #{json['type']} #{json['indicator']}"
  end

  def self.add_item_record_to_doc(doc, top_container, tag099_a)
    doc.xpath('//marc:datafield').last.next = top_container.item_record(tag099_a.content)
  end

  def self.create_and_log_item_record(container, top_container, params)
    add_item_record_to_doc(params.doc, top_container, params.tag099_a)
    json = JSON.parse(container['json'])
    log_container_creation(params.log_out, json)
  end
end

# This class processes archival containers and constructs MARC XML item records.
#
# Class workflow:
# 1. Load and validate Alma barcode data from CSV files
# 2. Fetch container records from ArchivesSpace API for a specific resource
# 3. Sort containers by indicator number for consistent processing order
# 4. Process each container individually, creating MARC records for valid ones
# 5. Log successful item record creation for audit and monitoring
#

# @example Basic usage
#   client = ArchivesSpace::Client.new(config)
#   params = Params.new(marc_doc, tag099_a, logger, nil)
#   constructor = ItemRecordConstructor.new(client)
#   constructor.construct_item_records("barcodes.csv", "/repositories/2/resources/123", params)
#
# @see ItemRecordUtils for utility functions
# @see TopContainer for container-specific logic
# @see Params for parameter structure
class ItemRecordConstructor
  REPO_PATH_REGEX = %r{(^/repositories/)(\d{1,2})(/resources.*$)}

  def initialize(client, barcode_duplicate_check)
    @client = client
    @barcode_duplicate_check = barcode_duplicate_check
  end

  attr_reader :barcode_duplicate_check, :client

  def construct_item_records(resource, params)
    containers = fetch_and_sort_containers(resource)

    return unless containers

    process_containers(containers, params)
  end

  private

  def fetch_containers(resource)
    repo = ItemRecordUtils.extract_repository_id(resource)
    @client.get("repositories/#{repo}/top_containers/search", query: { q: "collection_uri_u_sstr:\"#{resource}\"" })
  end

  def fetch_and_sort_containers(resource)
    containers_unfiltered = fetch_containers(resource)
    return unless containers_unfiltered&.parsed&.dig('response', 'docs')

    ItemRecordUtils.sort_containers_by_indicator(containers_unfiltered.parsed['response']['docs'])
  end

  def process_containers(containers, params)
    containers.select do |container|
      process_single_container(container, params)
    end
  end

  def process_single_container(container, params)
    top_container = TopContainer.new(container)
    return false unless container_valid?(top_container)

    ItemRecordUtils.create_and_log_item_record(container, top_container, params)
    true
  end

  def container_valid?(top_container)
    top_container.valid? && top_container.barcode && !barcode_duplicate_check.duplicate?(top_container.barcode)
  end
end
