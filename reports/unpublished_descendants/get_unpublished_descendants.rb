require 'archivesspace/client'
require 'active_support/all'
require 'nokogiri'
require_relative '../../helper_methods.rb'


@client = aspace_staging_login
output = "get_unpublished_descendants.txt"

def get_unpublished_descendants(tree)
  tree['children'].map do  |child|
    next if tree['has_children'] == false
    if child['publish'] == false
      child
    else
      get_unpublished_descendants(child).flatten.compact
    end
  end
end

records = get_all_records_for_repo_endpoint(5, "resources")
#sadly, the resolve parameter makes this time out; doing explicit API calls instead
published_resources = records.select { |record| record if record['publish'] == true}
published_resources.each do |published_resource|
  tree_ref = published_resource['tree']['ref']
  tree = @client.get(tree_ref).parsed
  unpublished_descendants = get_unpublished_descendants(tree)
  puts unpublished_descendants
  File.write(output, unpublished_descendants.flatten.compact, mode: 'a') unless unpublished_descendants.flatten.compact.empty?
end
