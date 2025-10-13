require 'archivesspace/client'
require 'active_support/all'
require 'csv'
require 'aspace_helper_methods'

aspace_login
output_file = "users_with_groups.csv"

CSV.open(output_file, "w",
         :write_headers => true,
         :headers => ["username", "name", "uri", "is active user", "is system user", "is admin", "repositories", "groups"]) do |row|
    repositories = (3..12).to_a
    repositories << 1

    groups = []
    repositories.each do |repo|
        @client.get("/repositories/#{repo}/groups").parsed.map do |group|
            #puts "#{group['uri']}, #{group['group_code']}, #{group['description']}, #{group['grants_permissions'].join(';')}"
            groups << "{#{group['uri']}=>['name'=>#{group['group_code']}, 'description'=>#{group['description']}, 'permissions'=>#{group['grants_permissions'].join(';')}]}"
        end
    end

    user_ids = @client.get('/users', {query: {
                             all_ids: true
                           }}).parsed

    user_records = []
    user_ids.each do |id|
        record = @client.get("/users/#{id}", {query: {
                               all_ids: true
                             }}).parsed
        user_records << {id => [
          {'repositories'=>record['permissions'].keys[0..-2].flatten}, #0
          {'username'=>record['username']}, #1
          {'name'=>record['name']}, #2
          {'is_system_user'=>record['is_system_user']}, #3
          {'is_active_user'=>record['is_active_user']}, #4
          {'is_admin'=>record['is_admin']}, #5
          {'uri'=>record['uri']}, #6
          {'groups'=>[]} #7
        ]}
    end

    user_records.each do |user_record|
        user_record.each_key do |id|
            record_by_id_key = user_records.find { |record| record.key?(id) }[id]
            repos = record_by_id_key[0]['repositories']
            unless repos.empty?
              repos.each do |repo|
                  user_with_groups = @client.get("#{repo}/users/#{id}").parsed
                  record_by_id_key[7]['groups'] << user_with_groups['groups']
              end
            end
            record_by_id_key[7]['groups'].flatten!
            row << [
              record_by_id_key[1]['username'],
              record_by_id_key[2]['name'],
              record_by_id_key[6]['uri'],
              record_by_id_key[3]['is_system_user'],
              record_by_id_key[4]['is_active_user'],
              record_by_id_key[5]['is_admin'],
              record_by_id_key[0]['repositories'].join(';'),
              record_by_id_key[7]['groups'].join(';')
            ]
        end
    end
end
