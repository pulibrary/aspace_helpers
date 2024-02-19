require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'


@client = aspace_staging_login
csv = CSV.parse(File.read("agents_parsed_dates.csv"), :headers => true)

puts Time.now

#get agent record from uri
csv[3..5].each do |row|
    @record = @client.get(row['uri']).parsed
    next if @record.nil?
    #make sure the agent record doesn't already have structured dates
    next if @record['dates_of_existence'].empty? == false

    #if both columns of the spreadsheet are populated,
    #construct a structured_date_range field
    if row['start'].blank? == false && row['end'].blank? == false
        @record['dates_of_existence'] <<
            {
            "date_type_structured"=>"range",
            "date_label"=>"existence",
            "jsonmodel_type"=>"structured_date_label",
            "structured_date_range"=>
                {
                "begin_date_standardized"=>row['start'],
                "end_date_standardized"=>row['end'],
                "created_by"=>"heberlei",
                "begin_date_standardized_type"=>"standard",
                "end_date_standardized_type"=>"standard",
                "jsonmodel_type"=>"structured_date_range"
                }
            }
        
    #if the first column of the spreadsheet is populated but the second is blank:
    #construct a structured_date_single field with role "begin"
    elsif row['end'].blank?
        record['dates_of_existence'] <<
            {
            "date_type_structured"=>"single",
            "date_label"=>"existence",
            "jsonmodel_type"=>"structured_date_label",
            "structured_date_single"=>
                {
                "date_standardized"=>row['start'],
                "date_role"=>"begin",
                "date_standardized_type"=>"standard",
                "jsonmodel_type"=>"structured_date_single"
                }
            }

    #if the second column of the spreadsheet is populated but the first is blank:
    #construct a structured_date_single field with role "end"
    elsif row['start'].blank?
        record['dates_of_existence'] <<
        {
        "date_type_structured"=>"single",
        "date_label"=>"existence",
        "jsonmodel_type"=>"structured_date_label",
        "structured_date_single"=>
            {
            "date_standardized"=>row['end'],
            "date_role"=>"end",
            "date_standardized_type"=>"standard",
            "jsonmodel_type"=>"structured_date_single"
            }
        }
    end
    add_maintenance_history(@record, "Added structured dates")
    post = @client.post(row['uri'], @record.to_json)
    puts post.body
end

puts Time.now

