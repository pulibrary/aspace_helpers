# frozen_string_literal: true

require 'mediawiki_api'

# this is the action api, documented here: https://www.mediawiki.org/wiki/Wikibase/API
# e.g. https://recordsincontexts.wikibase.cloud/w/api.php?action=wbgetentities&ids=Q73&format=json
# https://recordsincontexts.wikibase.cloud/wiki/Special:ApiSandbox

client = MediawikiApi::Client.new 'https://recordsincontexts.wikibase.cloud/w/api.php'
client.log_in 'Regineheberlein@gmail.com', 'Wikinu1sance!'
# get labels for two items
# item = client.action :wbgetentities, ids: ['Q73', 'Q74'], format: 'json'
# item.data['entities'].values.each do |item|
#     puts item['labels']['en']['value']
# end

# #protect an item
# #id takes an integer, which doesn't correspond to the item number though
# protect = client.action :protect,
#     :title => 'Item:Q74',
#     :protections => 'edit=sysop',
#     :reason => 'Wikidata entity',
#     :token => false

# protect an array of pages
# items = ["Item:Q28","Item:Q29","Item:Q30","Item:Q31","Item:Q33","Item:Q34","Item:Q35",
# "Item:Q36","Item:Q37","Item:Q57","Item:Q68","Item:Q69","Item:Q70","Item:Q71","Item:Q72",
# "Item:Q73","Item:Q74","Item:Q75","Item:Q76","Item:Q77","Item:Q78","Item:Q79","Item:Q80",
# "Item:Q81","Item:Q82","Item:Q83","Item:Q84","Item:Q85","Item:Q1204","Item:Q1207"]
# items.each do |item|
#     client.action :protect,
#         :title => "#{item}",
#         :protections => 'edit=sysop',
#         :reason => 'Wikidata entity',
#         :token => false
# end

# get a property label
item = client.action :wbgetentities, ids: ['P5'], format: 'json'
item.data['entities'].each_value do |item|
  puts item['labels']['en']['value']
end
