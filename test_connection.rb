# frozen_string_literal: true

require_relative 'helper_methods'

begin
  aspace_login
rescue ArchivesSpace::ConnectionError => e
  puts e.message
  exit 1
end

host = URI.parse(ENV.fetch('ASPACE_URL', nil)).host
puts "Successfully authenticated to #{host}"
