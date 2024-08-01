require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

puts Time.now

temporal_term = Regexp.new(/\d{1,2}(th|nd|d|st)\scentury/i)

subject_ids = @client.get(
  "/subjects", { query: { all_ids: true } }
).parsed
subjects_all =
  subject_ids.map {|subject_id| @client.get("/subjects/#{subject_id}").parsed}

    subjects_century = subjects_all.select do |subject|
            subject['title'] =~ /(--|—)\s?#{temporal_term}\.?\s?/
        end

    subjects_century.map do |subject|
        uri = subject['uri']
        next unless subject['terms'][0]['term'] =~ /(--|—)\s?#{temporal_term}\.?\s?$/

        #first, use the old string to construct a new facet and type
        subject['terms'] << {"term"=>subject['terms'][0]['term'].gsub(/(^.+?)(\s?(--|—)\s?)(#{temporal_term})(.*?$)/i, '\4'), "term_type"=>"temporal", "jsonmodel_type"=>"term", "vocabulary"=>"/vocabularies/1"}
        #then, delete all but the first term from the old string
        subject['terms'][0]['term'] = subject['terms'][0]['term'].gsub(/(^.+?)(\s?(--|—)\s?)(#{temporal_term})(.*?$)/i, '\1\6')
        add_maintenance_history(subject, "Subjects remediation: move temporal terms to $y")
        post = @client.post(uri, subject.to_json)
        puts post.body
    end

puts Time.now
