require 'archivesspace/client'
require 'active_support/all'
require 'json'
require_relative '../../helper_methods.rb'

aspace_login

eadids = %w[C0019
            C0039
            C0042
            C0050
            C0053
            C0065
            C0083
            C0086
            C0098
            C0109
            C0115
            C0116
            C0158
            C0198
            C0203
            C0209
            C0210
            C0236
            C0253
            C0259
            C0263
            C0267
            C0268
            C0294
            C0323
            C0325
            C0345
            C0346
            C0354
            C0375
            C0382
            C0383
            C0385
            C0387
            C0402
            C0405
            C0406
            C0407
            C0436
            C0456
            C0472
            C0475
            C0479
            C0482
            C0503
            C0520
            C0534
            C0548
            C0557
            C0558
            C0562
            C0571
            C0574
            C0589
            C0593
            C0600
            C0602
            C0616
            C0621
            C0626
            C0632
            C0637
            C0642
            C0647
            C0653
            C0662
            C0666
            C0670
            C0676
            C0682
            C0683
            C0687
            C0690
            C0705
            C0707
            C0708
            C0711
            C0721
            C0722
            C0740
            C0780
            C0784
            C0785
            C0786
            C0800
            C0804
            C0808
            C0809
            C0823
            C0833
            C0834
            C0842
            C0858
            C0861
            C0863
            C0872
            C0878
            C0912
            C0914
            C0919
            C0936
            C0939
            C0959
            C0969
            C0975
            C0980
            C0995
            C0996
            C1004
            C1014
            C1016
            C1026
            C1031
            C1043
            C1045
            C1057
            C1061
            C1074
            C1081
            C1084
            C1094
            C1095
            C1102
            C1108
            C1113
            C1116
            C1118
            C1125
            C1126
            C1127
            C1139
            C1146
            C1150
            C1157
            C1170
            C1176
            C1179
            C1184
            C1201
            C1213
            C1221
            C1230
            C1235
            C1239
            C1255
            C1262
            C1263
            C1270
            C1315
            C1318
            C1324
            C1325
            C1327
            C1335
            C1366
            C1372
            C1376
            C1379
            C1380
            C1386
            C1403
            C1409
            C1411
            C1415
            C1416
            C1423
            C1424
            C1440
            C1450
            C1453
            C1478
            C1482
            TC005
            TC047
            TC075
            WC010
            WC013
            C0299
            C0305
            C0331
            C0876
            C1079
            C1194]

resource_uris = get_uris_by_eadids(eadids)

top_containers =
  resource_uris.map do |k, _v|
    @client.get(
      'repositories/5/top_containers/search',
    query: {
      q: "collection_uri_u_sstr:\"#{k}\""
    }
    ).parsed['response']['docs']
end

top_containers.flatten!

CSV.open("top_containers_by_collection_2.csv", "a",
  :write_headers=> true,
  :headers => ["uri", "eadid", "collection_title", "container_type", "container_indicator", "barcode", "container_profile", "location", "location_note"]) do |row|
  top_containers.map do |result|
      row << [
        result['uri'],
        (result['collection_identifier_stored_u_sstr'][0] unless result['collection_identifier_stored_u_sstr'].nil?).to_s,
        (result['collection_display_string_u_sstr'][0] unless result['collection_display_string_u_sstr'].nil?).to_s,
        (result['type_enum_s'][0] unless result['type_enum_s'].nil?).to_s,
        (result['indicator_u_icusort'] unless result['indicator_u_icusort'].nil?).to_s,
        (result['barcode_u_sstr'][0] unless result['barcode_u_sstr'].nil?).to_s,
        (result['container_profile_display_string_u_sstr'][0] unless result['container_profile_display_string_u_sstr'].nil?).to_s,
        (result['location_display_string_u_sstr'][0] unless result['location_display_string_u_sstr'].nil?).to_s,
        (JSON.parse(result['json'])['container_locations'][0]['note'] unless result['json']['container_locations'][0]['note'].nil?).to_s
      ]
  end
end
