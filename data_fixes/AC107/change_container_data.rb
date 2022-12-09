require_relative '../../helper_methods.rb'
require_relative '../../csv_aspace_runner'

client = aspace_staging_login

runner = CSVASpaceRunner.new("AC107_Change_Container_Indicators.csv", client)

runner.run do |row, record|
  #get new values from csv
    new_profile = row['new_instance_profile']
    new_indicator = row['new_instance_indicator']
    new_location = row['new_location_uri']

  #replace fields with new values
    record['indicator'] = new_indicator
    record["container_profile"] = {'ref'=>"#{new_profile}"}
    record['container_locations'] = [{"jsonmodel_type"=>"container_location",
    "status"=>"current",
    "start_date"=>"2022-11-09}",
    "ref"=>"#{new_location}"
    }]

  end
