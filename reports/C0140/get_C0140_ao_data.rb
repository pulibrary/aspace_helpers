require 'archivesspace/client'
require 'json'
require 'nokogiri'
require_relative '../../helper_methods.rb'

def remove_tags(text_node)
  text_node.to_s.gsub!(/<\/?[\D\S]+?>/,'')
end

aspace_staging_login()

start_time = "Process started: #{Time.now}"
puts start_time

filename = "C0140_out.xml"
file =  File.open(filename, "w")
file << '<collection xmlns="http://www.loc.gov/MARC21/slim" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">'

#set these manually before running
resource_ids = [3950]
repo = 5
default_restriction = "Collection is open for research use."

#get components
resource_ids.each do |resource_id|
    ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed
#set up variables for each data point needed in the MARCxml
#data coming from the collection-level
    ao_tree['uris'].each do |ao_ref|

      level = ao_ref['level']
      depth = ao_ref['depth']
      ead_id = ao_ref['ead_id']
      ao_uris = []
      #exclude collection level
      ao_uris << ao_ref['ref'] unless ao_ref.dig('level') == 'collection'
#data coming from the component itself
      ao_uris.each do |uri|
        id = uri.gsub!(/(.*\/)+/, '')
        #get ao
        get_ao = get_single_archival_object_by_id(repo, id, resolve = ['subjects', 'top_container'])
        ref_id = get_ao['ref_id']
        title = get_ao['title']
        date_type = get_ao['dates'][0]['date_type']
        tag008_date_type =
          if date_type.match(/undated|(dates not examined)/i) || get_ao.dig('dates', 0, 'begin').nil?
            "n"
          else "e"
          end
        date1 = if get_ao.dig('dates', 0, 'begin')
                  get_ao['dates'][0]['begin']
                else "    " #4 blanks
                end
        date2 = if get_ao.dig('dates', 0, 'end')
                  get_ao['dates'][0]['end']
                else "    " #4 blanks
                end
        date_expression = get_ao['dates'][0]['expression']
        language = get_ao.dig('lang_materials', 0, 'language_and_script', 'language')
        tag008_langcode =
          if language
            language
          else "eng"
          end
        #process the notes requested
        notes = get_ao.dig('notes')
        restrictions_hash = notes.select { |hash| hash['type'] == "accessrestrict"}
        #restriction_type = restrictions_hash.map { |restriction| restriction['rights_restriction']['local_access_restriction_type'][0]}
        restriction_note = restrictions_hash.map { |restriction| remove_tags(restriction['subnotes'][0]['content'].gsub(/[\r\n]+/, ' '))}
        scope_hash = notes.select { |hash| hash['type'] == "scopecontent"}
        scope_notes = scope_hash.map { |scope| remove_tags(scope['subnotes'][0]['content'].gsub(/[\r\n]+/, ' ').gsub(/()<\/?p>/, ''))}
        related_hash = notes.select { |hash| hash['type'] == "relatedmaterial"}
        related_notes = related_hash.map { |related| remove_tags(related['subnotes'][0]['content'].gsub(/[\r\n]+/, ' '))}
        acq_hash = notes.select { |hash| hash['type'] == "acqinfo"}
        acq_notes = acq_hash.map { |acq| remove_tags(acq['subnotes'][0]['content'].gsub(/[\r\n]+/, ' '))}
        bioghist_hash = notes.select { |hash| hash['type'] == "bioghist"}
        bioghist_notes = bioghist_hash.map { |bioghist| remove_tags(bioghist['subnotes'][0]['content'].gsub(/[\r\n]+/), ' ')}

        extents = get_ao['extents']
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
        #puts "#{uri}, #{ead_id ||= ref_id}, #{title}, #{date_type}, #{date1 ||= date_expression}, #{date2 ||= ''}, #{language ||= ''}, #{level}, #{depth}, #{restriction_type || ""}, #{restriction_note || "Open for research"}, #{scope_note}, #{extents.join(', ')}, #{top_container}"

        # Agent/Creator/Persname or Famname	100
        # Agent/Creator/Corpname	110
        # Processing Information	583
        # Agent/Subject	600
        # Subjects	610
        # Subjects	611
        # Subjects	650
        # Subjects	651
        # Subjects	655
        # Agent/Creator	700
        # URL ?? + RefID (ex: https://findingaids.princeton.edu/catalog/C0140_c25673-42817)	856
        # Physical Location (can this be pulled from the collection-level note?)	982

        #adds controlfields
        leader = "<leader>00000namaa22000002u 4500</leader>"
        tag001 = "<controlfield tag='001'>#{ref_id}</controlfield>"
        tag003 = "<controlfield tag='003'>PULFA</controlfield>"
        tag008 = Nokogiri::XML.fragment("<controlfield tag='008'>000000#{tag008_date_type}#{date1}#{date2}xx      |           #{tag008_langcode} d</controlfield>")
        # addresses github 181 'Archival object URI??	035'
        tag035 = "<datafield ind1=' ' ind2=' ' tag='035'>
        <subfield code='a'>(PULFA)#{ref_id}</subfield>
        </datafield>"
        # addresses github 181 'Language	041'
        tag041 = "<datafield ind1=' ' ind2=' ' tag='041'>
          <subfield code='c'>#{tag008.content[35..37]}</subfield>
        </datafield>"
        # addresses github 181 'Dates/Expression	046'
        tag046 = "<datafield ind1=' ' ind2=' ' tag='046'>
          <subfield code='a'>i</subfield>
          <subfield code='c'>#{tag008.content[7..10]}</subfield>
          <subfield code='e'>#{tag008.content[11..14]}</subfield>
        </datafield>"
        # addresses github 181 'RefID (collection code?)/ Archival object URI??	099'
        tag099 = "<datafield ind1=' ' ind2=' ' tag='099'>
        <subfield code = 'a'>#{ref_id}</subfield>
        </datafield>"
        # addresses github 181 'Title	245'
        tag245 = "<datafield ind1=' ' ind2=' ' tag='245'>
        <subfield code = 'a'>#{title}</subfield>
        </datafield>"
        # addresses github 181 Extents	300
        # somewhat unelegant conditional but works without having to refactor the Nokogiri doc
        tag300 =
          if extents.count > 1
            repeatable_subfields =
              extents[1..].map do |extent|
                "<subfield code = 'a'>#{extent['number']}</subfield>
                 <subfield code = 'f'>#{extent['extent_type']})</subfield>"
              end
            Nokogiri::XML.fragment("<datafield ind1=' ' ind2=' ' tag='300'>
            <subfield code = 'a'>#{extents[0]['number']}</subfield>
            <subfield code = 'f'>#{extents[0]['extent_type']} (</subfield>
            #{repeatable_subfields}
          </datafield>")
          else
            Nokogiri::XML.fragment("<datafield ind1=' ' ind2=' ' tag='300'>
            <subfield code = 'a'>#{extents[0]['number']}</subfield>
            <subfield code = 'f'>#{extents[0]['extent_type']}</subfield>
            </datafield>")
          end
        #addresses github 181 'Conditions Governing Access (can this be pulled from the collection-level note if there is none at the component level?)	506'
        tag506 = "<datafield ind1=' ' ind2=' ' tag='506'>
        <subfield code = 'a'>#{restriction_note[0] ||= default_restriction}</subfield>
        </datafield>"
        # addresses github 181 'Scope and contents	520'
        tags520 = scope_notes.map do |scope_note|
          "<datafield ind1=' ' ind2=' ' tag='520'>
          <subfield code = 'a'>#{scope_note}</subfield>
          </datafield>"
        end
        # addresses github 181 'Immediate Source of Acquisition	541'
        tags541 = acq_notes.map do |acq_note|
          "<datafield ind1=' ' ind2=' ' tag='541'>
            <subfield code = 'a'>#{acq_note}</subfield>
            </datafield>"
        end
        # adds related materials note
        tags544 = related_notes.map do |related_note|
          "<datafield ind1=' ' ind2=' ' tag='544'>
            <subfield code = 'a'>#{related_note}</subfield>
            </datafield>"
        end
        #addresses github 181 '# Agents/Biographical/Historical note	545'
        tags545 = bioghist_notes.map do |bioghist_note|
          "<datafield ind1=' ' ind2=' ' tag='545'>
            <subfield code = 'a'>#{bioghist_note}</subfield>
            </datafield>"
        end

        record = Nokogiri::XML.fragment(
        "<record>
          #{leader}
          #{tag001}
          #{tag003}
          #{tag008}
          #{tag035}
          #{tag041}
          #{tag046}
          #{tag099}
          #{tag245}
          #{tag300}
          #{tag506}
          #{tags520.join(' ')}
          #{tags541.join(' ')}
          #{tags544.join(' ')}
          #{tags545.join(' ')}
        </record>"
)
        file << record

        rescue Exception => msg
        end_time = "Process interrupted at #{Time.now} with message '#{msg.class}: #{msg.message}''"
      end
    end
    file.flush
  end
file << '</collection>'
file.close
end_time = "Process ended: #{Time.now}"
puts end_time
