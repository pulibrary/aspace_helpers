require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'

aspace_login

resource_records = get_all_resource_records_for_institution

resource_records.select! { |resource| resource['ead_id'].blank? }

resource_records.map do |resource|
    puts "#{resource['uri']}, #{resource['title']}, #{resource['id_0']}, #{resource['id_1']}, #{resource['id_2']}, #{resource['id_3']}, #{resource['ead_id']}"
end
