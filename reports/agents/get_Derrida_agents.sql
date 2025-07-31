#704
SELECT lar.agent_person_id, lar.agent_corporate_entity_id, lar.agent_family_id 
FROM
linked_agents_rlshp lar
LEFT JOIN archival_object ao on ao.id = lar.archival_object_id 
WHERE ao.root_record_id = '1719' OR ao.root_record_id = '1720'
GROUP BY lar.agent_person_id, lar.agent_corporate_entity_id, lar.agent_family_id 
HAVING COUNT(*) = 1
