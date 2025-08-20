SELECT ao.id, 
       ao.ref_id, 
       r.ead_id, 
       ao.title, 
       ao.root_record_id,
       JSON_UNQUOTE(JSON_EXTRACT(CAST(n.notes AS CHAR CHARACTER SET utf8mb4), '$.subnotes[0].content')) AS content_value,
       CASE 
           WHEN fi.instance_type_id = 349 THEN 'yes'
           WHEN fi.instance_type_id = 353 THEN 'no'
           ELSE fi.instance_type_id
       END AS instance_type
FROM archival_object ao
LEFT JOIN resource r ON ao.root_record_id = r.id
LEFT JOIN note n ON ao.id = n.archival_object_id
LEFT JOIN (
    SELECT 
        ao.id AS archival_object_id,
        i.instance_type_id,
        ROW_NUMBER() OVER (PARTITION BY ao.id ORDER BY 
            CASE 
                WHEN i.instance_type_id = 349 THEN 1
                WHEN i.instance_type_id = 353 THEN 2
                ELSE 3
            END) AS rn
    FROM archival_object ao
    LEFT JOIN `instance` i ON ao.id = i.archival_object_id
) fi ON ao.id = fi.archival_object_id AND fi.rn = 1
WHERE JSON_UNQUOTE(JSON_EXTRACT(CAST(n.notes AS CHAR CHARACTER SET utf8mb4), '$.type')) = 'scopecontent'
AND (ao.root_record_id LIKE "3933"
 OR ao.root_record_id LIKE "3950"
 OR ao.root_record_id LIKE "3717"
 OR ao.root_record_id LIKE "3774"
 OR ao.root_record_id LIKE "3215"
 OR ao.root_record_id LIKE "3258"
 OR ao.root_record_id LIKE "3121"
 OR ao.root_record_id LIKE "3167"
 OR ao.root_record_id LIKE "2513"
 OR ao.root_record_id LIKE "3784"
 OR ao.root_record_id LIKE "4013"
 OR ao.root_record_id LIKE "3641"
 OR ao.root_record_id LIKE "3429"
 OR ao.root_record_id LIKE "3171"
 OR ao.root_record_id LIKE "3866"
 OR ao.root_record_id LIKE "2749"
 OR ao.root_record_id LIKE "3326"
 OR ao.root_record_id LIKE "2882"
 OR ao.root_record_id LIKE "3584"
 OR ao.root_record_id LIKE "3402"
 OR ao.root_record_id LIKE "2683"
 OR ao.root_record_id LIKE "4190"
 OR ao.root_record_id LIKE "4374"
 OR ao.root_record_id LIKE "4386"
 OR ao.root_record_id LIKE "2291"
 OR ao.root_record_id LIKE "2581"
 OR ao.root_record_id LIKE "2582"
 OR ao.root_record_id LIKE "2583"
 OR ao.root_record_id LIKE "2586"
 OR ao.root_record_id LIKE "2359"
 OR ao.root_record_id LIKE "2531"
 OR ao.root_record_id LIKE "2599"
 OR ao.root_record_id LIKE "2591"
 OR ao.root_record_id LIKE "2593"
 OR ao.root_record_id LIKE "2594"
 OR ao.root_record_id LIKE "2295"
 OR ao.root_record_id LIKE "2596"
 OR ao.root_record_id LIKE "2597"
 OR ao.root_record_id LIKE "2598"
 OR ao.root_record_id LIKE "2599"
 OR ao.root_record_id LIKE "2603"
 OR ao.root_record_id LIKE "2266"
 OR ao.root_record_id LIKE "2604"
 OR ao.root_record_id LIKE "2605"
 OR ao.root_record_id LIKE "2606"
 OR ao.root_record_id LIKE "2607")
AND 
(n.notes LIKE "%Altar%"
OR n.notes LIKE "%Cemetery%"
OR n.notes LIKE "%Ceremony%"
OR n.notes LIKE "%Chants%"
OR n.notes LIKE "%Church%"
OR n.notes LIKE "%Dance%"
OR n.notes LIKE "%Design%"
OR n.notes LIKE "%Funerary%"
OR n.notes LIKE "%Hospital%"
OR n.notes LIKE "%Kiva%"
OR n.notes LIKE "%Lodge%"
OR n.notes LIKE "%Mask%"
OR n.notes LIKE "%Medicine Man%"
OR n.notes LIKE "%Object%"
OR n.notes LIKE "%Paint%"
OR n.notes LIKE "%Pottery%"
OR n.notes LIKE "%Prayer%"
OR n.notes LIKE "%Rite%"
OR n.notes LIKE "%Ritual%"
OR n.notes LIKE "%Sacred%"
OR n.notes LIKE "%Shrine%"
OR n.notes LIKE "%Site%"
OR n.notes LIKE "%Song%"
OR n.notes LIKE "%Symbol%"
OR n.notes LIKE "%Village%"
OR n.notes LIKE "%Witchcraft");