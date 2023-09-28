require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login

queries = [
  'collection_uri_u_sstr:"/repositories/3/resources/1666"',
  'collection_uri_u_sstr:"/repositories/3/resources/1863"',
  'collection_uri_u_sstr:"/repositories/4/resources/2179"',
  'collection_uri_u_sstr:"/repositories/4/resources/2192"',
  'collection_uri_u_sstr:"/repositories/4/resources/4151"',
  'collection_uri_u_sstr:"/repositories/4/resources/4154"',
  'collection_uri_u_sstr:"/repositories/5/resources/3947"',
  'collection_uri_u_sstr:"/repositories/6/resources/1722"',
  'collection_uri_u_sstr:"/repositories/6/resources/1723"',
  'collection_uri_u_sstr:"/repositories/6/resources/1729"',
  'collection_uri_u_sstr:"/repositories/6/resources/1732"',
  'collection_uri_u_sstr:"/repositories/6/resources/1735"',
  'collection_uri_u_sstr:"/repositories/6/resources/1739"',
  'collection_uri_u_sstr:"/repositories/6/resources/1740"',
  'collection_uri_u_sstr:"/repositories/6/resources/1741"',
  'collection_uri_u_sstr:"/repositories/8/resources/4115"']

#'location_uri_u_sstr:"/locations/23648"'

top_containers =
  (0..15).to_a.map do |int|
    repo = queries[int].gsub(/collection_uri_u_sstr:"\/repositories\//, '').gsub(/\/resources\/\d{3,4}"/, '')
    @client.get(
    "repositories/#{repo}/top_containers/search",
    query: {
      q: queries[int]
    }
    ).parsed['response']['docs']
end

top_containers.flatten!

CSV.open("top_containers_by_collection_type_indicator.csv", "a",
  :write_headers=> true,
  :headers => ["uri", "eadid", "container_type", "container_indicator", "barcode"]) do |row|

  top_containers.map do |result|
      row << [
        result['uri'],
        (result['collection_identifier_stored_u_sstr'][0] unless result['collection_identifier_stored_u_sstr'].nil?).to_s,
        (result['type_enum_s'][0] unless result['type_enum_s'].nil?).to_s,
        (result['indicator_u_icusort'] unless result['indicator_u_icusort'].nil?).to_s,
        (result['barcode_u_sstr'][0] unless result['barcode_u_sstr'].nil?).to_s,
      ]
  end
end
