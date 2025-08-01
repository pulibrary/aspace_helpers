require 'archivesspace/client'
require 'active_support/all'
require 'net/sftp'
require 'nokogiri'
require 'csv'
require_relative '../../helper_methods.rb'
require_relative 'resource'
require_relative 'top_container'

#log errors to file
$stderr.reopen("log_err.txt", "w")
#keep values synced so they're not going to the buffer
$stderr.sync = true

remote_filename = "sc_active_barcodes.csv"

#configure sendoff to alma
def alma_sftp (filename)
  Net::SFTP.start(ENV.fetch('SFTP_HOST', nil), ENV.fetch('SFTP_USERNAME', nil), { password: ENV.fetch('SFTP_PASSWORD', nil) }) do |sftp|
    sftp.upload!(filename, File.join('/alma/aspace/', File.basename(filename)))
  end
end

#get Alma barcode report from sftp
def get_file_from_sftp(remote_filename)
  Net::SFTP.start(ENV.fetch('SFTP_HOST', nil), ENV.fetch('SFTP_USERNAME', nil), { password: ENV.fetch('SFTP_PASSWORD', nil) }) do |sftp|
    sftp.download!(File.join('/alma/aspace/', File.basename(remote_filename)), remote_filename)
  end
end

#rename old files so we never send an outdated file by accident
def rename_file(original_path, new_path)
  Net::SFTP.start(ENV.fetch('SFTP_HOST', nil), ENV.fetch('SFTP_USERNAME', nil), { password: ENV.fetch('SFTP_PASSWORD', nil) }) do |sftp|
    sftp.stat(original_path) do |response|
      sftp.rename!(original_path, new_path) if response.ok?
    end
  end
end

#remove files in preparation for renaming
def remove_file(path)
  Net::SFTP.start(ENV.fetch('SFTP_HOST', nil), ENV.fetch('SFTP_USERNAME', nil), { password: ENV.fetch('SFTP_PASSWORD', nil) }) do |sftp|
    sftp.stat(path) do |response|
      sftp.remove!(path) if response.ok?
    end
  end
end

def datestamp
  Time.now.utc.strftime('%Y%m%d%H%M')
end

def fetch_and_process_records(remote_filename)
  #open a quasi log to receive progress output
  log_out = File.open("log_out.txt", "w")
  aspace_login
  #log when the process started
  log_out.puts "Process started fetching records at #{Time.now}"
  filename = "MARC_out.xml"
  #get file from remote server
  get_file_from_sftp(remote_filename)
  remote_file = remote_filename
  #rename MARC file:
  #in case the export fails, this ensures that
  #Alma will not find a stale file to import
  remove_file("/alma/aspace/MARC_out_old.xml")
  rename_file("/alma/aspace/#{filename}", "/alma/aspace/MARC_out_old.xml")
  #rename barcodes report after download:
  #this will keep the process from running if
  #either the fresh report from Alma does not arrive
  #or the ASpace export fails
  remove_file("/alma/aspace/sc_active_barcodes_old.csv")
  rename_file("/alma/aspace/#{remote_filename}", "/alma/aspace/sc_active_barcodes_old.csv")

  #get collection records from ASpace
  resources = get_all_resource_uris_for_institution

  file =  File.open(filename, "w")
  file << '<collection xmlns="http://www.loc.gov/MARC21/slim" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">'

  resources.each do |resource_uri|
    process_resource(resource_uri, file, log_out, remote_file)
  end

  file << '</collection>'
  file.close

  #send to alma
  alma_sftp(filename)

  #log when the process finished.
  log_out.puts "Process finished at #{Time.now}"
end

def process_resource(resource, file, log_out, remote_file)
  retries ||= 0

  my_resource = Resource.new(resource, @client, file, log_out, remote_file)
  # uri = my_resource.marc_uri
  # marc_record = @client.get(uri)
  doc = my_resource.marc_xml

  # set up variables (these may return a sequence)
  ##################
  tag008 = my_resource.tag008

  tags040 = my_resource.tags040
  tag041 = my_resource.tag041
  tag099_a = my_resource.tag099_a
  tag351 = my_resource.tag351
  tags500 = my_resource.tags500
  tags500_a = my_resource.tags500_a
  tags520 = my_resource.tags520
  tags524 = my_resource.tags524
  tags535 = my_resource.tags535
  tags540 = my_resource.tags540
  tags541 = my_resource.tags541
  tags544 = my_resource.tags544
  tags561 = my_resource.tags561
  tags583 = my_resource.tags583
  tags852 = my_resource.tags852
  tag856 = my_resource.tag856
  tags6_7xx = my_resource.tags6_7xx
  subfields = my_resource.subfields

  #do stuff
  ##################

  #addresses github #128
  #recursively remove truly empty elements (blank text and empty attributes)
  my_resource.remove_empty_elements(doc)

  #addresses github #159
  my_resource.remove_linebreaks(doc)

  #addresses github #129
  tag008.previous=("<controlfield tag='001'>#{tag099_a.content}</controlfield>")

  #addresses github #130
  tag008.previous=("<controlfield tag='003'>PULFA</controlfield>")

  #addresses github #144
  #swap quotes so interpolation is possible
  tag008.next=("<datafield ind1=' ' ind2=' ' tag='035'>
    <subfield code='a'>(PULFA)#{tag099_a.content}</subfield>
    </datafield>")

  #addresses github #131
  tags040.each do |tag040|
    tag040.replace('<datafield ind1=" " ind2=" " tag="040">
        <subfield code="a">NjP</subfield>
        <subfield code="b">eng</subfield>
        <subfield code="e">dacs</subfield>
        <subfield code="c">NjP</subfield>
      </datafield>')
  end

  #addresses github #134
  tag041.next=("<datafield ind1=' ' ind2=' ' tag='046'>
        <subfield code='a'>i</subfield>
        <subfield code='c'>#{my_resource.tag008.content[7..10]}</subfield>
        <subfield code='e'>#{my_resource.tag008.content[11..14]}</subfield>
      </datafield>")

  #addresses github #168
  #superseded by github #379
  #  tags520 = tags520.map.with_index { |tag520, index| tag520.remove if index > 0}

  #addresses github #380 - limit scopenotes to 8000 characters
  # (9999b field size limit in Alma v. 40,000+ character notes in ASpace)
  tags520 = tags520.each do |tag520|
    #ASpace exports everything to $a, so only one subfield to check
    tag520.at_xpath('marc:subfield[@code="a"]').content = tag520.at_xpath('marc:subfield[@code="a"]').content.truncate(7999)
  end

  #addresses github #133
  #superseded by github #205
  #NB node.children.before inserts new node as first of node's children; default for add_child is last
  # tags544.each do |tag544|
  #   tag544.children.before('<subfield code="a">')
  # end

  #addresses github #143
  #adapted from Mark's implementation of Don's logic
  tags6_7xx.each do |tag6xx|
    subfield_a = tag6xx.at_xpath('marc:subfield[@code="a"]')
    segments = subfield_a.content.split('--')
    segments.each { |segment| segment.strip! }
    subfield_a_text = segments[0]
    new_subfield_a = subfield_a.replace("<subfield code='a'>#{subfield_a_text}</subfield")
    segments[1..-1].each do |segment|
      code = segment =~ /^[0-9]{2}/ ? 'y' : 'x'
      tag6xx.children.last.next=("<subfield code='#{code}'>#{segment}</subfield>")
    end
    #addresses github issue #334
    if tag6xx.at_xpath('marc:subfield[@code="0"]')
      subfield0 = tag6xx.at_xpath('marc:subfield[@code="0"]')
      if subfield0.content =~ /viaf/
         subfield0.replace("<subfield code='1'>#{subfield0.content}</subfield>")
      end
    end
    if tag6xx.at_xpath('marc:subfield[@code="2"]')
        subfield2 = tag6xx.at_xpath('marc:subfield[@code="2"]')
        ind2 = tag6xx.at_xpath('@ind2')
        if subfield2.content =~ /^viaf$/
            subfield2.remove
            if ind2.content == '7'
                ind2.content = '0'
            end
        end
    end

    #add punctuation to the last subfield except $2
    # if tag6xx.children[-1].attribute('code') == '2'
    #   tag6xx.children[-2].content << '.' unless ['?', '-', '.'].include?(tag6xx.children[-2].content[-1])
    # else
    #   tag6xx.children[-1].content << '.' unless ['?', '-', '.'].include?(tag6xx.children[-1].content[-1])
    # end
  end

  #addresses github #132
  tags852.each do |tag|
    tag.remove
  end

  #addresses github #268
  unless tag856.nil?
    #addresses github #264 and #265
    tag856.replace("<datafield ind1='4' ind2='2' tag='856'>
      <subfield code='z'>Search and Request</subfield>
      #{tag856.at_xpath('marc:subfield[@code="u"]')}
      <subfield code='y'>Princeton University Library Finding Aids</subfield>
    </datafield>")
  end

  #addresses github 147
  unless tags500_a.nil?
    tags500_a.select do |tag500_a|
      #the exporter adds preceding text and punctuation for each physloc.
      #hardcode location codes because textual physlocs are patterned the same
      #account for 'sca' prefix (#247)

      if tag500_a.content.match(/Location of resource: (sca)?(anxb|ea|ex|flm|flmp|gax|hsvc|hsvm|mss|mudd|prnc|rarebooks|rcpph|rcppf|rcppl|rcpxc|rcpxg|rcpxm|rcpxr|st|thx|wa|review|oo|sc|sls)/)
        #strip text preceding and following code
        location_notes = tag500_a.content.gsub(/.*:\s(.+)[.]/, "\\1")
        location_notes.split.each do |tag|
          #add as the last datafield
          doc.xpath('//marc:datafield').last.next=
          ("<datafield ind1=' ' ind2=' ' tag='982'><subfield code='c'>#{tag}</subfield></datafield>")
          end unless location_notes.nil?
      end
    end
  end

  #addresses github #397
  construct_item_records(remote_file, resource, doc, tag099_a, log_out)

  #addresses github #205
  tag351.remove unless tag351.nil?
  tags500.each(&:remove) unless tags500.nil?
  tags524.each(&:remove) unless tags524.nil?
  tags535.each(&:remove) unless tags535.nil?
  tags540.each(&:remove) unless tags540.nil?
  tags541.each(&:remove) unless tags541.nil?
  tags544.each(&:remove) unless tags544.nil?
  tags561.each(&:remove) unless tags561.nil?
  tags583.each(&:remove) unless tags583.nil?

  #log which records were finished when
  log_out.puts "Fetched record #{tag099_a.content} at #{Time.now}\n"

  #try adding a delay to get around the rate limit
  sleep(0.25)

  #append record to file
  #the unless clause addresses #186, #268, #284, #548, #553
  file << doc.at_xpath('//marc:record') unless tag099_a.content =~ /^(C0140|C1771|AC214|AC364|C0744.06|C0935|C1296|WC059|RBD1|RBD1.1)$/ || tag856.nil?
  file.flush
  log_out.flush
rescue Errno::ECONNRESET,Errno::ECONNABORTED,Errno::ETIMEDOUT,Errno::ECONNREFUSED => error
  while (retries += 1) <= 3
    log_out.puts "Encountered #{error.class}: '#{error.message}' when retrieving resource #{resource} at #{Time.now}, retrying in #{retries} second(s)..."
    sleep(retries)
    retry
  end
  log_out.puts "Encountered #{error.class}: '#{error.message}' at #{Time.now}, unsuccessful in retrieving resource #{resource} after #{retries} retries"
end

def construct_item_records(remote_file, resource, doc, tag099_a, log_out)
  alma_barcodes_array = CSV.read(remote_file).flatten.to_a
  alma_barcodes_set = alma_barcodes_array.to_set
  #get the repo so we only check in the relevant repo
  repo = resource.gsub(%r{(^/repositories/)(\d{1,2})(/resources.*$)}, '\2')
  #get container records for the resource
  containers_unfiltered = @client.get(
    "repositories/#{repo}/top_containers/search",
    query: { q: "collection_uri_u_sstr:\"#{resource}\"" }
  )
  containers =
    #sort by top_container indicator
    containers_unfiltered.parsed['response']['docs'].sort_by! { |container| JSON.parse(container['json'])['indicator'].scan(/\d+/).first.to_i }
    containers_unfiltered.parsed['response']['docs'].select do |container|
      json = JSON.parse(container['json'])
      top_container = TopContainer.new(container)
      if top_container.valid?(alma_barcodes_set)
        doc.xpath('//marc:datafield').last.next=
          top_container.item_record(tag099_a.content)
      log_out.puts "Created record for #{json['type']} #{json['indicator']}"
        end
      end unless containers_unfiltered.nil?
end

# If you run this file directly, the main method will run
# If you run the file from rspec, it will only run when calling the method
if $PROGRAM_NAME == __FILE__
  fetch_and_process_records(remote_filename)
end
