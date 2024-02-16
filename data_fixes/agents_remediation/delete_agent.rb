require 'archivesspace/client'
require 'active_support/all'
require_relative '../../helper_methods.rb'

aspace_login

csv = CSV.parse(File.read("delete_agents.csv"), :headers => true)

csv.each do |row|
    delete = @client.delete(row['uri'])
    puts delete.body
end
