require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

repos_all = (3..12).to_a

#this is what we're updating to
update_physloc = {
  "rcpxm" => "scarcpxm", # Manuscripts Remote Storage (ReCAP)
  "ctsn" => "scactsn", # Cotsen Children’s Library Archival
  "gax" => "scagax", # Graphic Arts Archival
  "mss" => "scamss", # Manuscripts Archival
  "wa" => "scawa", # Western Americana Archival
  "ex" => "scaex", # Rare Books Archival
  "hsvm" => "scahsvm", # Manuscripts High Security Archival
  "mudd" => "scamudd", # Mudd Archival
  "thx" => "scathx" # Theater Archival
}

#this is for testing and in case we need to revert
revert_physloc = {
  "scarcpxm"	 => "rcpxm" 	,	 # Manuscripts Remote Storage (ReCAP)
  "scactsn"	 => "ctsn" 	,	 # Cotsen Children’s Library Archival
  "scagax"	 => "gax" 	,	 # Graphic Arts Archival
  "scamss"	 => "mss" 	,	 # Manuscripts Archival
  "scawa"	 => "wa" 	,	 # Western Americana Archival
  "scaex"	 => "ex" 	,	 # Rare Books Archival
  "scahsvm"	 => "hsvm" 	,	 # Manuscripts High Security Archival
  "scamudd"	 => "mudd" 	,	 # Mudd Archival
  "scathx"	 => "thx" 		 # Theater Archival
}

#iterate over all repositories
repos_all.each do |repo|
#iterate over all resources within repositories
resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    uri = resource['uri']
    #filter out all physloc notes
    physloc_all = resource['notes'].select { |note| note["type"] == "physloc" }
    #create empty array to hold update trigger after looping
    update = []
    #iterate over all physloc notes
    physloc_all.each do |physloc|
      #skip if empty; they throw an ASpace error otherwise
      next if physloc['content'].empty?
      #the the content--it's an array of 1
      physloc_text = physloc['content'][0]
      #update the pertinent codes
      update_physloc.each do |k,v|
        if k.match?(/^#{physloc_text}\s?$/)
          # puts "#{k} : '#{physloc_text}' : #{uri}"
          #if there was a match, record that in the update array
          update << true
          physloc['content'][0] = physloc_text.gsub!(k, v)
        else next
        end
      end
    end
    #puts "update after physlocs: #{update.include?(true)} : #{uri}"
    #post only if there was a match
    if update.include?(true)
      #write a revision statement to the record at the same time
      add_resource_revision_statement(resource, "Updated physloc code")
      post = @client.post(uri, resource.to_json)
      puts post.body
    end
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
