require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative 'helper_methods.rb'


@client = aspace_staging_login

morrison = get_agent_by_id("people", 11175)
puts morrison
