#704
SELECT *
FROM (
    SELECT 
        lar.agent_person_id, 
        lar.agent_corporate_entity_id, 
        lar.agent_family_id,
        MAX(ao.root_record_id) AS root_record_id,
        COUNT(*) AS rel_count
    FROM linked_agents_rlshp lar
    LEFT JOIN archival_object ao ON ao.id = lar.archival_object_id 
    LEFT JOIN resource r ON r.id = lar.resource_id 
    LEFT JOIN digital_object do ON do.id = lar.digital_object_id 
    GROUP BY 
        lar.agent_person_id, 
        lar.agent_corporate_entity_id, 
        lar.agent_family_id
) grouped
WHERE grouped.rel_count = 1
  AND (grouped.root_record_id = '1719' or grouped.root_record_id = '1720');
