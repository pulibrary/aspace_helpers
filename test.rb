require 'archivesspace/client'
require_relative 'helper_methods.rb'

aspace_local_login()

record = get_single_archival_object_by_id('2', '58844')
puts record
