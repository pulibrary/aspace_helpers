require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

@client = aspace_login
csv = CSV.parse(File.read("DO_NOT_EDIT-agents_parsed_dates.csv"), :headers => true)

puts Time.now

csv.each do |row|
    @record = @client.get(row['uri']).parsed
    next if @record.nil?

    @record['dates_of_existence'] = if row['start'].blank?
        [
          {
            "date_type_structured"=>"single",
          "date_label"=>"existence",
          "date_certainty"=>row['date_certainty'],
          "jsonmodel_type"=>"structured_date_label",
          "structured_date_single"=>
              {
                "date_expression"=>row['date_expression'],
              "date_role"=>"end",
              "date_standardized"=>row['end'],
              "created_by"=>"heberlei",
              "date_standardized_type"=>"standard",
              "jsonmodel_type"=>"structured_date_single"
              }
          }
        ]
        else
        [
          {
            "date_type_structured"=>"range",
          "date_label"=>"existence",
          "date_certainty"=>row['date_certainty'],
          "jsonmodel_type"=>"structured_date_label",
          "structured_date_range"=>
              {
                "begin_date_standardized"=>row['start'],
              "begin_date_expression"=>row['date_expression'],
              "end_date_standardized"=>row['end'],
              "created_by"=>"heberlei",
              "begin_date_standardized_type"=>"standard",
              "end_date_standardized_type"=>"standard",
              "jsonmodel_type"=>"structured_date_range"
              }
          }
        ]
        end
    @record['names'] = [
      {
        "jsonmodel_type"=>"name_person",
      "name_order"=>"inverted",
      "sort_name_auto_generate"=>true,
      "primary_name"=>row['last'],
      "rest_of_name"=>row['first'],
      "fuller_form"=>row['fuller_form'],
      "suffix"=>row['suffix'],
      "number"=>row['number'],
      "dates"=>row['dates'],
      "prefix"=>row['prefix'],
      "title"=>row['title']
      }
    ]

    add_maintenance_history(@record, "Agents remediation")
    post = @client.post(row['uri'], @record.to_json)
    puts post.body
end

puts Time.now
