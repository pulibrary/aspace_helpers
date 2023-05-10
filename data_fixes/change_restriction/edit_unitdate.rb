require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time

log = "log_aclu_restrictions_20230509.csv"
csv = CSV.parse(File.read("ACLU Paralegal Review Data Collection - Import 2023-05.csv"), :headers => true)

  csv.each do |row|
    record = @client.get(row['uri']).parsed
    record['dates'][0]['expression'] = row['date_expression']
    record['dates'][0]['begin'] = row['begin_date']
    record['dates'][0]['end'] = row['end_date']
    post = @client.post(row['uri'], record.to_json)
    #write to log
    File.write(log, post.body, mode: 'a')
    puts post.body

    rescue Exception => msg
    error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
    puts error
end

puts "Process ended #{Time.now}."
