require 'archivesspace/client'
require 'json'
require_relative '../helper_methods.rb'

aspace_login

output_file = "schema.csv"
schemas = @client.get("/schemas").parsed
start_time = "Process started: #{Time.now}"

def db_schemas_to_csv(hash, csv, level = 0)
    hash.each_key do |k|
        if hash[k].is_a?(Hash)
            nested_hash = hash[k]
            csv << [CSV.parse(" ", :col_sep=>',')*level, k].flatten
            db_schemas_to_csv(nested_hash, csv, level+1)
        else
            csv << [CSV.parse(" ", :col_sep=>',')*level, "#{k}: #{hash[k]}"].flatten
        end
    end
end

CSV.open(output_file, "w", :write_headers => false) do |csv|
    db_schemas_to_csv(schemas, csv)
end
