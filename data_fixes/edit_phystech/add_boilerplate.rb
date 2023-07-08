require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods'

aspace_login

log = 'add_boilerplate_log.txt'
csv = CSV.parse(File.read('replace_phystech.csv'), headers: true)

start_time = "Process started: #{Time.now}"
puts start_time

boilerplate = "For preservation reasons, original analog
and digital media may not be read or played back in the
reading room. Users may visually inspect physical media
but may not remove it from its enclosure. All analog
audiovisual media must be digitized to preservation-quality
standards prior to use. Audiovisual digitization requests
are processed by an approved third-party vendor. Please note,
the transfer time required can be as little as several weeks
to as long as several months and there may be financial costs
associated with the process.
Requests should be directed through the
<extref xlink:href='https://library.princeton.edu/special-collections/ask-us' xlink:type='simple'>Ask Us Form</extref>."

repos = (3..5).to_a
repos.each do |repo|
  #get resource ids
  resource_ids = @client.get("/repositories/#{repo}/resources", {
    query: {
     all_ids: true
   }}).parsed
  #get records from ids
  records =
    resource_ids.map do |id|
      @client.get("/repositories/#{repo}/resources/#{id}").parsed
    end
  #iterate through all records
  records.each do |record|
    uri = record['uri']
    new_phystech =
      { 'jsonmodel_type' => 'note_multipart',
        'subnotes' => [{ 'publish' => true,
                         'jsonmodel_type' => 'note_text',
                         'content' => boilerplate }],
        'type' => 'phystech',
        'publish' => true }
    record['notes'] = record['notes'].prepend(new_phystech)

    post = @client.post(uri, record.to_json)
      puts post.body
      # write to log
      File.write(log, post.body, mode: 'a')
  end
rescue Exception => e
  error = "Process ended: #{Time.now} with error '#{e.class}: #{e.message}''"
  puts error
end
end_time = "Process ended: #{Time.now}"
puts end_time
