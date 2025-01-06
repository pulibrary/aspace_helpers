require 'archivesspace/client'
require 'active_support/all'
require_relative 'helper_methods.rb'

@client = aspace_login

repositories = (3..12).to_a
count_all = repositories.map do |repo|
    @client.get("/repositories/#{repo}/resources",
        query: {
          all_ids: true
        }).parsed.count
        end
puts count_all.flatten.sum
