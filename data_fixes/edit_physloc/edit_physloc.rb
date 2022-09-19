require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

repos_all = (3..12).to_a

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

repos_all.each do |repo|

resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    uri = resource['uri']
    physloc_all = resource['notes'].select { |note| note["type"] == "physloc" }
    update = []
    physloc_all.each do |physloc|
      next if physloc['content'].empty?
      physloc_text = physloc['content'][0]
      update_physloc.each do |k,v|
        if k.match?(/^#{physloc_text}\s?$/)
          # puts "#{k} : '#{physloc_text}' : #{uri}"
          update << true
          physloc['content'][0] = physloc_text.gsub!(k, v)
        else next
        end
      end
    end
    #puts "update after physlocs: #{update.include?(true)} : #{uri}"
    if update.include?(true)
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
