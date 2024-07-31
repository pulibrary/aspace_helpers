require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

@client = aspace_staging_login

puts Time.now

genreterms = ["Archives",
              "Bibliography",
              "Biography",
              "Caricatures and cartoons",
              "Catalogs",
              "Correspondence",
              "Designs and plans",
              "Dictionaries",
              "Drama",
              "Drawings",
              "Early works to 1800",
              "Facsimiles",
              "Fiction",
              "Folklore",
              "In art",
              "Manuscripts Facsimiles",
              "Maps",
              "Miscellanea",
              "Newspapers",
              "Pamphlets",
              "Periodicals",
              "Photographs",
              "Pictorial works",
              "Posters",
              "Prayers and devotions",
              "Records and correspondence",
              "Slides",
              "Songs and music",
              "Sources",
              "Specimens",
              "Statistics",
              "Textbooks",
              "Texts",
              "Translations"]

subject_ids = @client.get(
  "/subjects", { query: { all_ids: true } }
).parsed
subjects_all =
  subject_ids.map {|subject_id| @client.get("/subjects/#{subject_id}").parsed}

genreterms.each do |genreterm|
    subjects_correspondence = subjects_all.select do |subject|
            subject['title'] =~ /(--|—)\s?#{genreterm}\.?\s?$/
        end

    subjects_correspondence.map do |subject|
        uri = subject['uri']
        next unless subject['terms'][0]['term'] =~ /(--|—)\s?#{genreterm}/

        subject['terms'][0]['term'] = subject['terms'][0]['term'].gsub(/(^.+?)(\s?(--|—)\s?)(#{genreterm})(.*?$)/, '\1\5')
        subject['terms'] << {"term"=>genreterm.capitalize.to_s, "term_type"=>"genre_form", "jsonmodel_type"=>"term", "vocabulary"=>"/vocabularies/1"}
        add_maintenance_history(subject, "Subjects remediation: move genre terms to $v")
        post = @client.post(uri, subject.to_json)
        puts post.body
    end
end

puts Time.now
