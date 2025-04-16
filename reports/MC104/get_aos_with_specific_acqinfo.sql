SELECT DISTINCT
    ao.id as ao_id
  , ao.ref_id
  , ao.display_string 
  , tc.barcode as barcode
  , tc.indicator as box_number
  , MAX(CASE WHEN n.notes LIKE "%accessrestrict%" THEN REGEXP_REPLACE(n.notes, '(.+content\":\")(.+?)(\",\".+)', '$2') END) as accessrestrict
  , MAX(CASE WHEN n.notes LIKE "%acqinfo%" THEN REGEXP_REPLACE(n.notes, '(.+content\":\")(.+?)(\",\".+)', '$2') END) as acqinfo
FROM sub_container sc
JOIN top_container_link_rlshp tclr on tclr.sub_container_id = sc.id
JOIN top_container tc on tclr.top_container_id = tc.id
JOIN instance on sc.instance_id = instance.id
JOIN archival_object ao on instance.archival_object_id = ao.id
LEFT JOIN note n on n.archival_object_id  = ao.id
WHERE ao.root_record_id = 1718 
GROUP BY ao.id
HAVING acqinfo LIKE '%ML-2025-002%'
ORDER BY ao.ref_id
