require 'archivesspace/client'
require 'active_support/all'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

# ---- Configuration: edit these per run, then nothing else needs to change ----
ENVIRONMENT = :staging # :staging or :production
REPO_ID = 13
CONTAINER_PROFILE_URI = "/container_profiles/31".freeze
INPUT_PATH = "/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/AI_experiment/add_inventory/SPA002_mf.csv".freeze
# --------------------------------------------------------------------------

ENVIRONMENT == :production ? aspace_login : aspace_staging_login

puts "Process started: #{Time.now} (environment: #{ENVIRONMENT}, repo: #{REPO_ID})"
#create containers from CSV
csv = CSV.parse(File.read(INPUT_PATH), :headers => true)

headers = csv.headers.dup
headers << 'container_uri' unless headers.include?('container_uri')
rows_out = []

def write_csv(path, headers, rows_out)
  CSV.open(path, "w") do |csv_out|
    csv_out << headers
    rows_out.each { |r| csv_out << headers.map { |h| r[h] } }
  end
end

# If a barcode already exists on a top_container in this repository, reuse that
# container: fill in its location/collection to match this row, and return its uri.
def reuse_existing_container(repo_id, barcode, location_ref, resource_ref, eadid)
  result = @client.get("/repositories/#{repo_id}/top_containers/search", {
                         query: { "q" => "barcode_u_sstr:#{barcode}", "page" => 1 }
                       }).parsed
  docs = result.dig('response', 'docs') || []
  return nil if docs.empty?

  uri = docs.first['uri']
  record = @client.get(uri).parsed
  record['container_locations'] = [
    {
      "jsonmodel_type" => "container_location",
      "start_date" => Time.now.strftime("%Y-%m-%d"),
      "status" => "current",
      "ref" => location_ref
    }
  ]
  record['collection'] = [{ "ref" => resource_ref, "identifier" => eadid }]
  post = @client.post(uri, record)
  parsed = post.parsed
  return uri if parsed.is_a?(Hash) && parsed['status'] == 'Updated'

  nil
end

csv.each_with_index do |row, i|
  record =
    {
      jsonmodel_type: "top_container",
      indicator: (row['value']).to_s,
      type: "Item",
      barcode: (row['label']).to_s,
      container_locations: [
        {
          "jsonmodel_type"=>"container_location",
          "start_date"=>Time.now.strftime("%Y-%m-%d"),
          "status"=>"current",
          "ref"=>(row['altrender']).to_s
        }
      ],
      collection: [{"ref"=>row['resource'], "identifier"=>row['eadid']}],
      container_profile: {"ref"=>CONTAINER_PROFILE_URI},
      restricted: true
    }

  row_hash = row.to_h

  begin
    post = @client.post("/repositories/#{REPO_ID}/top_containers", record)
    parsed = post.parsed
    if parsed.is_a?(Hash) && parsed['status'] == 'Created' && parsed['uri']
      row_hash['container_uri'] = parsed['uri']
      puts "Row #{i + 1}/#{csv.length}: created #{parsed['uri']} (barcode #{row['label']}, indicator #{row['value']})"
    elsif post.body.to_s.include?('barcode must be unique')
      reused_uri = reuse_existing_container(REPO_ID, row['label'].to_s, row['altrender'].to_s, row['resource'].to_s, row['eadid'].to_s)
      if reused_uri
        row_hash['container_uri'] = reused_uri
        puts "Row #{i + 1}/#{csv.length}: reused existing #{reused_uri} (barcode #{row['label']}, indicator #{row['value']})"
      else
        row_hash['container_uri'] = "ERROR: duplicate barcode but could not reuse: #{post.body}"
        puts "Row #{i + 1}/#{csv.length}: ERROR reusing duplicate barcode #{row['label']}: #{post.body}"
      end
    else
      row_hash['container_uri'] = "ERROR: #{post.body}"
      puts "Row #{i + 1}/#{csv.length}: ERROR (barcode #{row['label']}): #{post.body}"
    end
  rescue StandardError => e
    row_hash['container_uri'] = "ERROR: #{e.class}: #{e.message}"
    puts "Row #{i + 1}/#{csv.length}: EXCEPTION (barcode #{row['label']}): #{e.class}: #{e.message}"
  end

  rows_out << row_hash
  write_csv(INPUT_PATH, headers, rows_out)
end

puts "Process finished: #{Time.now}"
