require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

@client = aspace_login

start_time = "Process started: #{Time.now}"
puts start_time
csv = CSV.parse(File.read("JBOH Scope and Contents Enhancement.csv"), :headers => true)
#collection_uri = get_single_resource_by_eadid(3, "MC212")
#>> /repositories/3/resources/1586

aos = @client.get('/repositories/3/resources/1586/ordered_records')
refs = aos.parsed['uris']
uris = []
refs[1..].each do |ref|
  uris << ref['ref']
end

aos_all = []
uris.each do |uri|
  aos_all << @client.get(uri)
end

aos_selected = []
aos_all.select do |ao|
  aos_selected << ao.parsed if csv['refid'].include?(ao.parsed['ref_id'])
end

aos_selected.each do |ao|
  ao['notes'].append(
    {
      "jsonmodel_type"=>"note_multipart",
    "type"=>"scopecontent",
    "subnotes"=>[
      {
        "jsonmodel_type"=>"note_text",
        "content"=>csv.find { |row| row['refid'] == ao['ref_id']}['note'],
        "publish"=>true
      }
    ],
    "publish"=>true
    }
  )
post = @client.post(ao['uri'], ao.to_json)
puts post.body
end
