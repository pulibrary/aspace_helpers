require_relative '../../helper_methods.rb'
require_relative '../../csv_aspace_runner'

client = aspace_staging_login

runner = CSVASpaceRunner.new("import_09_28_22.csv", client)

runner.run do |row, record|
    #accessrestrict might need to be overwritten or created
    new_accessrestrict =
        {
        "jsonmodel_type"=>"note_multipart",
        "type"=>"accessrestrict",
        "rights_restriction"=>{"end"=>row['end_date'] ||= '',
        "local_access_restriction_type"=>[row['restriction_type']]},
        "subnotes"=>[{"jsonmodel_type"=>"note_text",
        "content"=>row['restriction_note'],
        "publish"=>true}],
        "publish"=>true
        }
    accessrestrict = record['notes'].select { |note| note["type"] == "accessrestrict" }[0]
    if accessrestrict.nil? == false
      accessrestrict = accessrestrict.replace(new_accessrestrict)
    else
      if record['notes'].any?
        then record['notes'] << new_accessrestrict
      else record['notes'] = [new_accessrestrict]
      end
    end
  end
