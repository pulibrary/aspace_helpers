# frozen_string_literal: true

require 'archivesspace/client'
require 'json'
require 'nokogiri'
require_relative '../../helper_methods'

def remove_tags(text)
  text.to_s.gsub(%r{</?[\D\S]+?>}, '')
end

aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

filename = 'C0140_out.xml'
file =  File.open(filename, 'w')
file << '<collection xmlns="http://www.loc.gov/MARC21/slim" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">'

# set these manually before running
resource_ids = [3950]
repo = 5
default_restriction = 'Collection is open for research use.'

# get components
resource_ids.each do |resource_id|
  ao_tree = @client.get("/repositories/#{repo}/resources/#{resource_id}/ordered_records").parsed
  # set up variables for each data point needed in the MARCxml
  # data coming from the collection-level
  ao_tree['uris'].each do |ao_ref|
    ao_uris = []
    # exclude collection level
    ao_uris << ao_ref['ref'] unless ao_ref['level'] == 'collection'
    # data coming from the component itself
    ao_uris.each do |uri|
      id = uri.gsub!(%r{(.*/)+}, '')
      # get ao
      get_ao = get_single_archival_object_by_id(repo, id, resolve = %w[subjects linked_agents top_container])
      ref_id = get_ao['ref_id']
      title = get_ao['title']
      date_type = get_ao['dates'][0]['date_type']
      tag008_date_type =
        if date_type.match(/undated|(dates not examined)/i) || get_ao.dig('dates', 0, 'begin').nil?
          'n'
        else
          'e'
        end
      date1 = if get_ao.dig('dates', 0, 'begin')
                get_ao['dates'][0]['begin']
              else
                '    ' # 4 blanks
              end
      date2 = if get_ao.dig('dates', 0, 'end')
                get_ao['dates'][0]['end']
              else
                '    ' # 4 blanks
              end
      date_expression = get_ao['dates'][0]['expression']
      language = get_ao.dig('lang_materials', 0, 'language_and_script', 'language')
      tag008_langcode =
        language || 'eng'
      # process the notes requested
      notes = get_ao['notes']
      restrictions_hash = notes.select { |hash| hash['type'] == 'accessrestrict' }
      restriction_note = restrictions_hash.map do |restriction|
        remove_tags(restriction['subnotes'][0]['content'].gsub(/[\r\n]+/, ' '))
      end
      scope_hash = notes.select { |hash| hash['type'] == 'scopecontent' }
      scope_notes = scope_hash.map { |scope| remove_tags(scope['subnotes'][0]['content'].gsub(/[\r\n]+/, ' ')) }
      related_hash = notes.select { |hash| hash['type'] == 'relatedmaterial' }
      related_notes = related_hash.map do |related|
        remove_tags(related['subnotes'][0]['content'].gsub(/[\r\n]+/, ' '))
      end
      acq_hash = notes.select { |hash| hash['type'] == 'acqinfo' }
      acq_notes = acq_hash.map { |acq| remove_tags(acq['subnotes'][0]['content'].gsub(/[\r\n]+/, ' ')) }
      bioghist_hash = notes.select { |hash| hash['type'] == 'bioghist' }
      bioghist_notes = bioghist_hash.map do |bioghist|
        remove_tags(bioghist['subnotes'][0]['content'].gsub(/[\r\n]+/, ' '))
      end
      processinfo_hash = notes.select { |hash| hash['type'] == 'processinfo' }
      processinfo_notes = processinfo_hash.map do |processinfo|
        remove_tags(processinfo['subnotes'][0]['content'].gsub(/[\r\n]+/, ' '))
      end

      extents = get_ao['extents']
      # process agents
      agents = get_ao['linked_agents']
      agents_processed = agents.map do |agent|
        {
          'role' => agent['role'],
          'relator' => agent['relator'],
          'type' => agent['_resolved']['jsonmodel_type'],
          'source' => agent['_resolved']['names'][0]['source'],
          'primary_name' => agent['_resolved']['names'][0]['primary_name'],
          'rest_of_name' => agent['_resolved']['names'][0]['rest_of_name'],
          'name_dates' => agent['_resolved']['names'][0]['use_dates'],
          'sort_name' => agent['_resolved']['names'][0]['sort_name'],
          'identifier' => agent['_resolved']['names'][0]['authority_id'],
          'name_order' => agent['_resolved']['names'][0]['name_order']
        }
      end
      # process locations
      instances = get_ao['instances'].select {|instance| instance['instance_type'] == "mixed_materials"}
      top_containers = instances.map do |instance|
        if instance['sub_container'].nil? == false
          instance['sub_container']['top_container']['_resolved']
        elsif instance['top_container']
          instance['top_container']['_resolved']
        end
      end
      top_container_location_record = top_containers.map do |top_container|
        @client.get(top_container['container_locations'][0]['ref']).parsed
      end
      top_container_location_code = top_container_location_record[0]['classification']

      subjects = get_ao['subjects']
      subjects_filtered = subjects.select do |subject|
        subject['_resolved']['terms'][0]['term_type'] == 'cultural_context' ||
        subject['_resolved']['terms'][0]['term_type'] == 'topical' ||
        subject['_resolved']['terms'][0]['term_type'] == 'geographic' ||
        subject['_resolved']['terms'][0]['term_type'] == 'genre_form'
      end
      subjects_processed = subjects_filtered.map do |subject|
        #index 0 here is wrong
        {
          'type' => subject['_resolved']['terms'][0]['term_type'],
          'source' => subject['_resolved']['source'],
          'full_first_term' => subject['_resolved']['terms'][0]['term'],
          'main_term' => subject['_resolved']['terms'][0]['term'].split('--')[0],
          'terms' => subject['_resolved']['terms']
        }
      end
      # adds controlfields
      leader = '<leader>00000namaa22000002u 4500</leader>'
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
      tag046 =
        if tag008.content[7..10] =~ /\d{4}/ || tag008.content[11..14] =~ /\d{4}/
          "<datafield ind1=' ' ind2=' ' tag='046'>
              <subfield code='a'>i</subfield>
              <subfield code='c'>#{tag008.content[7..10]}</subfield>
              <subfield code='e'>#{tag008.content[11..14]}</subfield>
            </datafield>"
        end
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
      # addresses github 181 'Conditions Governing Access (can this be pulled from the collection-level note if there is none at the component level?)	506'
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
      # addresses github 181 '# Agents/Biographical/Historical note	545'
      tags545 = bioghist_notes.map do |bioghist_note|
        "<datafield ind1=' ' ind2=' ' tag='545'>
            <subfield code = 'a'>#{bioghist_note}</subfield>
            </datafield>"
      end

      # addresses github 181 'Processing Information	583'
      tags583 = processinfo_notes.map do |processinfo_note|
        "<datafield ind1=' ' ind2=' ' tag='583'>
            <subfield code = 'a'>#{processinfo_note}</subfield>
            </datafield>"
      end

      # addresses github 181 'Agent/Creator/Persname or Famname	100'
      # addresses github 181 'Agent/Creator/Corpname	110'
      # addresses github 181 'Agent/Subject	6xx'
      # addresses github 181 'Agent/Subject	7xx'
      tags6xx_agents =
        # process tag number
        agents_processed.map do |agent|
          tag =
            if agent['role'] == 'creator' && (agent['type'] == 'agent_person' || agent['relator'] == 'agent_family')
              700
            elsif agent['role'] == 'subject' && (agent['type'] == 'agent_person' || agent['relator'] == 'agent_family')
              600
            elsif (agent['role'] == 'creator' || agent['role'] == 'source') && agent['type'] == 'agent_corporate_entity'
              710
            elsif agent['role'] == 'subject' && agent['type'] == 'agent_corporate_entity'
              610
            end
          name_type =
            # we don't know in ASpace whether a name is a jurisdication name or first name only
            if agent['type'] == 'agent_person'
              1
            elsif agent['type'] == 'agent_family'
              3
            elsif agent['type'] == 'agent_corporate_entity' && agent['name_order'] == 'inverted'
              0
            elsif agent['type'] == 'agent_corporate_entity'
              2
            end
          source_code = agent['source'] == 'lcnaf' ? 0 : 7
          name =
            if agent['rest_of_name'].nil?
              agent['primary_name']
            else
              "#{agent['primary_name']}, #{agent['rest_of_name']}"
            end
          dates = "<subfield code='d'>#{agent['name_dates']}</subfield>"
          subfield_e = agent['relator'].nil? ? nil : "<subfield code='e'>#{agent['relator']}</subfield>"
          subfield_2 = source_code == 7 ? "<subfield code = '2'>#{agent['source']}</subfield>" : nil
          add_punctuation = agent['name_dates'].empty? ? '.' : ','
          subfield_0 = agent['identifier'].nil? ? nil : "<subfield code = '0'>#{agent['identifier']}</subfield>"
          # create 1xx
          @tag1xx =
            if agent['role'] == 'creator'
              "<datafield ind1='#{name_type}' ind2='#{source_code}' tag='1#{tag.to_s[1..2]}'>
                <subfield code = 'a'>#{name}#{add_punctuation unless name[-1] =~ /[.,)-]/}</subfield>
                #{dates unless agent['name_dates'].empty?}
                #{subfield_e ||= ''}
                #{subfield_2 ||= ''}
                #{subfield_0 ||= ''}
              </datafield>"
            end
          "<datafield ind1='#{name_type}' ind2='#{source_code}' tag='#{tag}'>
            <subfield code = 'a'>#{name}#{add_punctuation unless name[-1] =~ /[.,)-]/}</subfield>
            #{dates unless agent['name_dates'].empty?}
            #{subfield_e ||= ''}
            #{subfield_2 ||= ''}
            #{subfield_0 ||= ''}
          </datafield>"
        end

      # addresses github 181 'Subjects	650'
      # addresses github 181 'Subjects	651'
      # addresses github 181 'Subjects	655'
      tags6xx_subjects =
        # process tag number
        # puts "#{subjects_processed}: #{subjects_processed.count}"
        subjects_processed.map do |subject|
          tag =
            case subject['type']
            when 'cultural_context'
              647
            when 'topical'
              655
            when 'geographic'
              650
            when 'temporal'
              650
            when 'genre_form'
              651
            end
          source_code = subject['source'] == 'lcsh' ? 0 : 7
          main_term = subject['main_term']
          subterms = subject['terms'][1..].map do |subterm|
            subfield_code =
              case subterm['term_type']
              when 'temporal', 'style_period', 'cultural_context'
                'y'
              when 'genre_form'
                'v'
              when 'geographic'
                'z'
              else
                'x'
              end
            # "#{subterm['term_type']}: #{subfield_code}: #{subterm['term'].strip}"
            "<subfield code = '#{subfield_code}'>#{subterm['term'].strip}</subfield>"
          end
          #if there are no subfields but the main term has double dashes, compute supfields
          computed_subterms =
            if subject['terms'].count == 1 && subject['full_first_term'] =~ /--/
              tokens = subject['full_first_term'].split('--')
              tokens.each(&:strip!)
              tokens[1..].map do |token|
                subfield_code = token =~ /^[0-9]{2}/ ? 'y' : 'x'
                "<subfield code = '#{subfield_code}'>#{token}</subfield>"
              end
            end
          #add subfield 2 if source code is 7
          subfield_2 = source_code == 7 ? "<subfield code = '2'>#{subject['source']}</subfield>" : nil

          #puts "#{main_term}: #{tag}: #{source_code}: #{subterms.join(', ')}"

          #put the field together
          "<datafield ind1=' ' ind2='#{source_code}' tag='#{tag}'>
            <subfield code = 'a'>#{main_term}</subfield>
              #{subterms.join(' ')}
              #{computed_subterms.join(' ') unless computed_subterms.nil?}
              #{subfield_2}
            </datafield>"
        end

      # addresses github 181 'URL ?? + RefID (ex: https://findingaids.princeton.edu/catalog/C0140_c25673-42817)	856'
      tag856 = "<datafield ind1='4' ind2='2' tag='856'>
          <subfield code = 'z'>Finding aid online: </subfield>
          <subfield code = 'u'>https://findingaids.princeton.edu/catalog/#{ref_id}</subfield>
          </datafield>"

      # addesses github 181 'Physical Location (can this be pulled from the collection-level note?)	982'
      tag982 = "<datafield ind1=' ' ind2=' ' tag='982'><subfield code='c'>#{top_container_location_code}</subfield></datafield>"

      # assemble the record
      record = Nokogiri::XML.fragment(
        "<record>
          #{leader}
          #{tag001}
          #{tag003}
          #{tag008}
          #{tag035}
          #{tag041}
          #{tag046 ||= ''}
          #{tag099}
          #{@tag1xx ||= ''}
          #{tag245}
          #{tag300}
          #{tag506}
          #{tags520.join(' ')}
          #{tags541.join(' ')}
          #{tags544.join(' ')}
          #{tags545.join(' ')}
          #{tags583.join(' ')}
          #{tags6xx_subjects.join(' ')}
          #{tags6xx_agents.join(' ')}
          #{tag856}
          #{tag982}
        </record>"
      )
      file << record

    rescue Exception => e
      end_time = "Process interrupted at #{Time.now} with message '#{e.class}: #{e.message}''"
    end
  end
  file.flush
end
file << '</collection>'
file.close
end_time = "Process ended: #{Time.now}"
puts end_time
