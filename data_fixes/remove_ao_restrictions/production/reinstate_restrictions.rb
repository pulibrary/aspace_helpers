require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../../helper_methods'

aspace_staging_login

log = 'add_restrictions_log.txt'
csv = CSV.parse(File.read('undelete_restrictions_5.csv'), headers: true)

start_time = "Process started: #{Time.now}"
puts start_time

csv.each do |row|
  record = @client.get(row['self_uri']).parsed
  has_restriction = record['notes'].select { |hash| hash['type'] == 'accessrestrict' }
  unless has_restriction.nil?
    restriction_note = row['self_restriction_note']
    restriction_type = [row['self_restriction_type']]
    restriction =
      { 'jsonmodel_type' => 'note_multipart',
        'subnotes' => [{ 'publish' => true,
                         'jsonmodel_type' => 'note_text',
                         'content' => restriction_note }],
        'type' => 'accessrestrict',
        'rights_restriction' => { 'local_access_restriction_type' => restriction_type },
        'publish' => true }
    record['notes'] = record['notes'].append(restriction)
    post = @client.post(row['self_uri'], record.to_json)
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
