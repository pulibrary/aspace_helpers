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

repos_all.each do |repo|

resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    physloc_all = resource['notes'].select { |note| note["type"] == "physloc" }
    physloc_all.each do |physloc|
      physloc_text = physloc['content'][0]
      update_physloc.each do |k,v|
        physloc['content'][0] =
          if physloc_text.match(k)
            physloc_text.gsub!(k, v)
            uri = resource['uri']
            post = @client.post(uri, resource.to_json)
            puts post.body
          else next
          end
        end
    end
  rescue Exception => msg
  error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
  end
  puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
