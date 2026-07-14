require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

eadid = "MC104.04"
resource_ids = [1718]

repo = 3
output_file = "#{eadid}.csv"

CSV.open(output_file, "a",
         :write_headers => true,
         :headers => ["uri", "eadid_or_ref_id", "title", "date", "level", "depth", "restriction_type", "restriction_note", "acqinfo", "container"]) do |row|
  resource_ids.each do |resource_id|
    ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed

    ao_tree['uris'].each do |ao_ref|
      @depth = ao_ref['depth']
      ao_uris = []
      #toggle collection-level line on or off
      ao_uris << ao_ref['ref'] #unless ao_ref.dig('level') == 'collection'

      ao_uris.each do |uri|
        get_ao = @client.get(uri).parsed
          ead_id = get_ao.dig('ead_id')
          ref_id = get_ao['ref_id']
          title = get_ao['title']
          date = get_ao['dates'][0]['expression']
          level = get_ao['level']
          depth = get_ao['depth']
          notes = get_ao.dig('notes')
          restrictions_hash = notes.select { |hash| hash['type'] == "accessrestrict"}
          restriction_type = restrictions_hash.dig(0, 'rights_restriction', 'local_access_restriction_type', 0)
          restriction_note =
            unless restrictions_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
              restrictions_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
            end
          acqinfo_hash = notes.select { |hash| hash['type'] == "acqinfo"}
          acqinfo_note =
            unless acqinfo_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
              acqinfo_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
            end
          top_container = nil
          sub_container = nil
          get_ao.dig('instances').each do |instance|
            next unless instance['instance_type'] == "mixed_materials"

            top_container_record =
              if instance.dig('sub_container').nil? == false
                @client.get(instance['sub_container']['top_container']['ref']).parsed
              elsif instance.dig('top_container')
                @client.get(instance['top_container']['ref']).parsed
              end
            top_container =
              # adding this failsafe after it hiccupped, though I don't fully understand why it's needed
              if top_container_record.nil?
                ""
              else
                "#{top_container_record['type']} #{top_container_record['indicator']}"
              end
            sub_container =
              if instance.dig('sub_container').nil? == false
                sub1 = "#{instance.dig('sub_container', 'type_2')} #{instance.dig('sub_container', 'indicator_2')}"
                unless instance.dig('sub_container', 'type_3').nil?
                  sub2 = "#{instance.dig('sub_container', 'type_3')} #{instance.dig('sub_container', 'indicator_3')}"
                end
                "#{sub1} #{sub2}"
              end
          end
          row << [uri, (ead_id ||= ref_id).to_s, title, date, level, @depth, (restriction_type || '').to_s, (restriction_note || '').to_s, (acqinfo_note || '').to_s, "#{top_container || ''} #{sub_container || ''}"]
          puts "#{uri}, #{ead_id ||= ref_id}, #{title}, #{date}, #{level}, #{@depth}, #{restriction_type || ''}, #{restriction_note || ''}, #{acqinfo_note || ''}, #{top_container || ''} #{sub_container || ''}"
        rescue Exception => msg
          end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
      end
    end
  end
end

end_time = "Process ended: #{Time.now}"
puts end_time
