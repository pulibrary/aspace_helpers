require 'archivesspace/client'
require 'active_support/all'
require_relative 'helper_methods.rb'
require 'csv'

@client = aspace_login

output_file = "users.csv"
CSV.open(output_file, "w",
         :write_headers => true,
         :headers => ["username", "name", "is active user", "repositories", "permissions"]) do |row|
    users = @client.get("/users", {
                          query: {
                            all_ids: true
                          }
                        }).parsed
    # puts users

    users.each do |id|
    user = @client.get("/users/#{id}").parsed
    repositories = user['permissions'].keys.join(', ')
    permissions =
      user['permissions'].map do |k, v|
          "#{k}: #{v.join(', ')}"
      end
    # Including the username field is essential to this report.  We include it in the file despite
    # bearer's privacy concerns, with the understanding that the report output will be kept secure.
    # bearer:disable ruby_lang_file_generation
    row << [user['username'], user['name'], user['is_active_user'], repositories, permissions[0]]
    end
end
