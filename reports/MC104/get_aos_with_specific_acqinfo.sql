SELECT DISTINCT
    ao.id as ao_id
  , ao.ref_id
  , ao.display_string 
  , tc.barcode as barcode
  , tc.indicator as box_number
  , MAX(CASE WHEN n.notes LIKE "%accessrestrict%" THEN REGEXP_REPLACE(n.notes, '(.+content\":\")(.+?)(\",\".+)', '$2') END) as accessrestrict
  , MAX(CASE WHEN n.notes LIKE "%acqinfo%" THEN REGEXP_REPLACE(n.notes, '(.+content\":\")(.+?)(\",\".+)', '$2') END) as acqinfo
FROM archival_object ao 
LEFT JOIN note n on ao.id = n.archival_object_id
LEFT JOIN instance i on ao.id = i.archival_object_id
LEFT JOIN sub_container sc on i.id = sc.instance_id
LEFT JOIN top_container_link_rlshp tclr on sc.id = tclr.sub_container_id
LEFT JOIN top_container tc on tclr.top_container_id = tc.id
WHERE ao.root_record_id = 1718 
GROUP BY ao.id
HAVING acqinfo LIKE '%ML-2025-002%'
ORDER BY ao.id
