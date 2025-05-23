require 'archivesspace/client'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login

start_time = "Process started: #{Time.now}"
puts start_time
log = "log_userestrict.txt"

userestrict_note = "<p>Single copies may be made for research purposes. To cite or publish quotations
that fall within Fair Use, as defined under <extref
xlink:href='http://copyright.princeton.edu/basics/fair-use' xlink:type='simple'>U. S. Copyright Law</extref>,
no permission is required. The Trustees of Princeton University hold copyright to all materials generated
by Princeton University employees in the course of their work.  For instances beyond Fair Use,
if copyright is held by Princeton University, researchers do not need to obtain permission, complete any
forms, or receive a letter to move forward with use of materials from the Princeton University Archives.</p>
<p>For instances beyond Fair Use where the copyright is not held by the University, while  permission from
the Library is not required, it is the responsibility of the researcher to determine whether any permissions
related to copyright, privacy, publicity, or any other rights are necessary for their intended use of the
Library's materials, and to obtain all required permissions from any existing rights holders, if they have
not already done so. Princeton University Library’s Special Collections does not charge any permission or
use fees for the publication of images of materials from our collections, nor does it require researchers
to obtain its permission for said use. The department does request that its collections be properly cited
and images credited. More detailed information can be found on the <extref
xlink:href='https://library.princeton.edu/special-collections/policies/copyright-credit-and-citation-guidelines'
xlink:type='simple'>Copyright, Credit and Citations Guidelines</extref> page on our website. If you have any
questions, please feel free to contact us through the <extref
xlink:href='https://library.princeton.edu/special-collections/ask-us' xlink:type='simple'>Ask Us! form</extref>.</p>"
repos_all = (4..4).to_a

#iterate over all repositories
repos_all.each do |repo|
#iterate over all resources within repositories
resources = get_all_records_for_repo_endpoint(repo, "resources")
  resources.each do |resource|
    uri = resource['uri']
    #filter out all accessrestrict notes
    userestrict_all = resource['notes'].select { |note| note["type"] == "userestrict" }
    #iterate over all access notes
    userestrict_all.each do |userestrict|
        if userestrict.empty?
            record['notes'].append(
              {
                "jsonmodel_type"=>"note_multipart",
              "type"=>"userestrict",
              "subnotes"=>[
                {
                  "jsonmodel_type"=>"note_text",
                  "content"=>userestrict_note,
                  "publish"=>true
                }
              ],
              "publish"=>true
              }
            )
        else
            userestrict['subnotes'][0]['content'] = userestrict_note
        end
    end
    #write a revision statement to the record at the same time
    add_resource_revision_statement(resource, "Updated use restriction")
    post = @client.post(uri, resource.to_json)
    puts post.body
    File.write(log, post.body, mode: 'a')
  end
rescue Exception => msg
error = "Process ended: #{Time.now} with error '#{msg.class}: #{msg.message}''"
puts error
end

end_time = "Process ended: #{Time.now}"
puts end_time
