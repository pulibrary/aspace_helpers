require 'archivesspace/client'
require 'json'
require 'csv'
require_relative '../../../helper_methods'

aspace_staging_login

start_time = "Process started: #{Time.now}"
puts start_time

filename = 'get_aggregate_review_restrictions.txt'

CSV.open(filename, 'wb',
         write_headers: true,
         headers: %w[ao_uri id title restriction_type restriction_note]) do |row|
  # get resource records for each repo
  repos = [3..12]
  repos.each do |repo|
    resource_records = get_all_records_for_repo_endpoint(repo, 'resources')
    # get the tree for each resource
    resource_records.each do |resource_record|
      resource_uri = resource_record['uri']
      ao_tree = @client.get("#{resource_uri}/ordered_records").parsed
      ao_uris = []
      # get each tree component's uri
      ao_tree['uris'].each do |ao_ref|
        ao_uris << ao_ref['ref']
      end
      ao_uris.each do |ao_uri|
        ao_record = @client.get(ao_uri).parsed
        # filter for aggregates, i.e. components that don't have a parent component; this includes collection-level records
        next unless ao_record['parent'].nil?

        accessrestrict_review = ao_record['notes'].select do |note|
          note['type'] == 'accessrestrict' && note['rights_restriction']['local_access_restriction_type'][0] == 'Review'
        end
        restriction_type = accessrestrict_review.dig(0, 'rights_restriction', 'local_access_restriction_type', 0)
        restriction_note = accessrestrict_review.dig(0, 'subnotes', 0, 'content')
        next if accessrestrict_review.empty?

        level = ao_record['level']
        id =
          if ao_record.dig('ref_id')
            ao_record['ref_id']
          else
            resource_record['ead_id']
          end
        title =
          if ao_record.dig('display_string')
            ao_record['display_string']
          else
            resource_record['title']
          end
        row << [ao_uri, id, title, restriction_type, restriction_note]
        puts "#{ao_uri}, #{id}, #{title}, #{restriction_type}, #{restriction_note}"
        # unless
      end # ao_uris
    end # resource_records.each
  end # repos.each
end # csv

start_time = "Process started: #{Time.now}"
puts start_time
