require 'archivesspace/client'
require 'active_support/all'
require 'json'
require 'csv'
require 'aspace_helper_methods'

aspace_login

eadids = %w[C0014
            C0232
            C0395
            C0641
            C0790
            C0812
            C0827
            C0915
            C1123
            C1229
            C1283
            C1358
            C1393
            C1439
            C1457
            C1475
            C1479
            C1480
            C1603]

resource_uris = get_uris_by_eadids(eadids)
resource_uris.map! do |string|
    string.split(',').first
end

top_containers =
  resource_uris.map do |uri|
  parsed = @client.get(
    'repositories/5/top_containers/search',
    query: {
      q: "collection_uri_u_sstr:\"#{uri}\""
    }
  ).parsed
    parsed['response']['docs']
end

top_containers.flatten!

CSV.open("top_containers_by_collection_4.csv", "a",
  :write_headers=> true,
  :headers => ["uri", "eadid", "collection_title", "container_type", "container_indicator", "barcode", "container_profile", "location", "location_note"]) do |row|
  top_containers.map do |result|
      row << [
        result['uri'],
        (result['collection_identifier_stored_u_sstr'][0] unless result['collection_identifier_stored_u_sstr'].nil?).to_s,
        (result['collection_display_string_u_sstr'][0] unless result['collection_display_string_u_sstr'].nil?).to_s,
        (result['type_enum_s'][0] unless result['type_enum_s'].nil?).to_s,
        (result['indicator_u_icusort'] unless result['indicator_u_icusort'].nil?).to_s,
        (result['barcode_u_sstr'][0] unless result['barcode_u_sstr'].nil?).to_s,
        (result['container_profile_display_string_u_sstr'][0] unless result['container_profile_display_string_u_sstr'].nil?).to_s,
        (result['location_display_string_u_sstr'][0] unless result['location_display_string_u_sstr'].nil?).to_s,
        (JSON.parse(result['json'])['container_locations'][0]['note'] unless result['json']['container_locations'][0]['note'].nil?).to_s
      ]
  end
end
