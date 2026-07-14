require 'archivesspace/client'
require 'active_support/all'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

# ---- Configuration: edit these per run, then nothing else needs to change ----
ENVIRONMENT = :staging # :staging or :production
INPUT_PATH = "/Users/heberleinr/Documents/aspace_helpers/data_fixes/LAE/AI_experiment/add_inventory/SPA002_mf.csv".freeze
AO_URI = "/repositories/13/archival_objects/1579411".freeze
INSTANCE_TYPE = "microform".freeze
# --------------------------------------------------------------------------

ENVIRONMENT == :production ? aspace_login : aspace_staging_login

puts "Process started: #{Time.now} (environment: #{ENVIRONMENT}, ao: #{AO_URI})"

#link containers to ao
csv = CSV.parse(File.read(INPUT_PATH), :headers => true)

headers = csv.headers.dup
headers << 'linked' unless headers.include?('linked')
rows_out = []

def write_csv(path, headers, rows_out)
  CSV.open(path, "w") do |csv_out|
    csv_out << headers
    rows_out.each { |r| csv_out << headers.map { |h| r[h] } }
  end
end

csv.each_with_index do |row, i|
  container_uri = row['container_uri']
  row_hash = row.to_h

  begin
    record = @client.get(AO_URI).parsed
    record['instances'] ||= []
    record['instances'].append(
      {
        instance_type: INSTANCE_TYPE,
        jsonmodel_type: "instance",
        is_representative: false,
        sub_container: {
          jsonmodel_type: "sub_container",
          top_container: {ref: container_uri}
        }
      }
    )
    post = @client.post(AO_URI, record)
    parsed = post.parsed
    if parsed.is_a?(Hash) && parsed['status'] == 'Updated'
      row_hash['linked'] = 'yes'
      puts "Row #{i + 1}/#{csv.length}: linked #{container_uri} to #{AO_URI}"
    else
      row_hash['linked'] = "ERROR: #{post.body}"
      puts "Row #{i + 1}/#{csv.length}: ERROR linking #{container_uri}: #{post.body}"
    end
  rescue StandardError => e
    row_hash['linked'] = "ERROR: #{e.class}: #{e.message}"
    puts "Row #{i + 1}/#{csv.length}: EXCEPTION linking #{container_uri}: #{e.class}: #{e.message}"
  end

  rows_out << row_hash
  write_csv(INPUT_PATH, headers, rows_out)
end

puts "Process finished: #{Time.now}"
