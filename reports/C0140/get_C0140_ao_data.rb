require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login()

start_time = "Process started: #{Time.now}"
puts start_time

resource_ids = [3950]
repo = 5

resource_ids.each do |resource_id|
    ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed

    ao_tree['uris'].each do |ao_ref|
      level = ao_ref['level']
      depth = ao_ref['depth']
      ead_id = ao_ref['ead_id']
      ao_uris = []
      #exclude collection level
      ao_uris << ao_ref['ref'] unless ao_ref.dig('level') == 'collection'

      ao_uris.each do |uri|
        # get_ao = @client.get(uri).parsed
        id = uri.gsub!(/(.*\/)+/, '')
        get_ao = get_single_archival_object_by_id(repo, id, resolve = ['subjects', 'top_container'])
          ref_id = get_ao['ref_id']
          title = get_ao['title']
          date = get_ao['dates'][0]['expression']
          notes = get_ao.dig('notes')
          restrictions_hash = notes.select { |hash| hash['type'] == "accessrestrict"}
          restriction_type = restrictions_hash.dig(0, 'rights_restriction', 'local_access_restriction_type', 0)
          restriction_note =
                unless
                  restrictions_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
                  restrictions_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
                end #unless
          scope_hash = notes.select { |hash| hash['type'] == "scopecontent"}
          scope_note =
                unless
                  scope_hash.dig(0, 'subnotes', 0, 'jsonmodel_type') != "note_text"
                  scope_hash.dig(0, 'subnotes', 0, 'content').gsub(/[\r\n]+/, ' ')
                end #unless
          extents = get_ao['extents'].map { |extent| "#{extent['number']} #{extent['extent_type']}" }
          #initialize instance objects
          top_container = nil
          sub_container = nil
          top_container_location = nil
          #digital_object_exists = false
          get_ao.dig('instances').each do |instance|
            if instance['instance_type'] == "mixed_materials"
            top_container_record =
              if instance.dig('sub_container').nil? == false
                #@client.get(instance['sub_container']['top_container']['ref']).parsed
                instance['sub_container']['top_container']['_resolved']
              else
                if instance.dig('top_container')
                  #@client.get(instance['top_container']['ref']).parsed
                  instance['top_container']['_resolved']
                end
              end
            end
            top_container =
              unless top_container_record.nil?
                top_container_record['long_display_string']
              end
            #digital_object_exists = instance['instance_type'] == "digital_object"
          end
          subjects = get_ao.dig('subjects')
          subjects_resolved = subjects.map do |subject|
            "#{subject['_resolved']['source']}"
            subject['_resolved']['terms'].map do |term|
              "#{term['term']} #{term['term_type']}"
            end
          end
          puts "#{uri}, #{ead_id ||= ref_id}, #{title}, #{date}, #{level}, #{depth}, #{restriction_type || ""}, #{restriction_note || "Open for research"}, #{scope_note}, #{extents.join(', ')}, #{top_container}"
          rescue Exception => msg
          end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
      end
    end
  end

end_time = "Process ended: #{Time.now}"
puts end_time
