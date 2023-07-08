require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods'

aspace_login

log = 'replace_phystech_log.txt'
csv = CSV.parse(File.read('replace_phystech.csv'), headers: true)

start_time = "Process started: #{Time.now}"
puts start_time

csv.each do |row|
  uri = row['uri']
  record = @client.get(uri).parsed
  new_phystech =
    { 'jsonmodel_type' => 'note_multipart',
      'subnotes' => [{ 'publish' => true,
                       'jsonmodel_type' => 'note_text',
                       'content' => row['new_phystech'] }],
      'type' => 'phystech',
      'publish' => true }
  notes = record['notes']

    notes.delete_if { |note| note["type"] == 'phystech' && row['new_phystech'].nil?}
    notes.select { |note| note['type'] == 'phystech'}[0]&.replace(new_phystech)
    post = @client.post(uri, record.to_json)
    puts post.body
    # write to log
    File.write(log, post.body, mode: 'a')

rescue Exception => e
  error = "Process ended: #{Time.now} with error '#{e.class}: #{e.message}''"
  puts error
end
end_time = "Process ended: #{Time.now}"
puts end_time
