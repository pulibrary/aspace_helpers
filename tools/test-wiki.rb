# this is the action api, documented here: https://www.mediawiki.org/wiki/Wikibase/API
# e.g. https://recordsincontexts.wikibase.cloud/w/api.php?action=wbgetentities&ids=Q73&format=json
# https://recordsincontexts.wikibase.cloud/wiki/Special:ApiSandbox

client = MediawikiApi::Client.new "https://recordsincontexts.wikibase.cloud/w/api.php"
client.log_in "user", "pw" 
# get labels for two items
# item = client.action :wbgetentities, ids: ['Q73', 'Q74'], format: 'json'
# item.data['entities'].values.each do |item|
#     puts item['labels']['en']['value']
# end

#protect an item
protect = client.action :protect, :title => 'Item:Q73', :protections => 'edit=sysop', :reason => 'Wikidata entity', :token => false

