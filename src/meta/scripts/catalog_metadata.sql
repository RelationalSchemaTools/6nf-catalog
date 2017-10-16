INSERT INTO meta.entity_type (entity_type_code, name, primary_key_data_type)
VALUES ('b', 'Base', 'uuid')
,      ('ba', 'Abstract Base', 'uuid')
,      ('s', 'Subtype', 'uuid')
,      ('r', 'Reference List', 'smallint');


INSERT INTO meta.entity (entity_name, entity_type_code)
SELECT e.value->>'name' AS entity_name
     , e.value->>'entity_type_code' AS entity_type_code
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_array_elements(cm.config#>'{entities}') AS e;


INSERT INTO meta.base_entity_attribute (entity_name, attribute_name, data_type, nullable, is_subtype_attribute)
SELECT e.value->>'name' AS entity_name
     , c.value->>'name' AS attribute_name
     , CASE WHEN c.value->>'references' IS NOT NULL THEN
     	    (SELECT _et.primary_key_data_type
               FROM meta.entity _e
                    JOIN meta.entity_type _et
                    ON _e.entity_type_code = _et.entity_type_code
              WHERE c.value->>'references' = _e.entity_name)
       ELSE 
            c.value->>'data_type'
       END AS data_type
     , (c.value->>'nullable')::boolean AS nullable
     , false AS is_subtype_attribute
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_array_elements(cm.config#>'{entities}') AS e
       
       CROSS JOIN jsonb_array_elements(e.value#>'{attributes}') AS c
 WHERE e.value->>'entity_type_code' IN ('b', 'ba');

INSERT INTO meta.base_entity_attribute (entity_name, attribute_name, data_type, nullable, is_subtype_attribute)
SELECT e.value->>'name' AS entity_name
     , c.value->>'name' AS attribute_name
     , CASE WHEN c.value->>'references' IS NOT NULL THEN
     	    (SELECT _et.primary_key_data_type
               FROM meta.entity _e
                    JOIN meta.entity_type _et
                    ON _e.entity_type_code = _et.entity_type_code
              WHERE c.value->>'references' = _e.entity_name)
       ELSE 
            c.value->>'data_type'
       END AS data_type
     , true AS nullable
     , true AS is_subtype_attribute
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_array_elements(cm.config#>'{entities}') AS e
       
       CROSS JOIN jsonb_array_elements(e.value#>'{subtype_attributes}') AS c
 WHERE e.value->>'entity_type_code' IN ('b', 'ba');


INSERT INTO meta.subtype_entity_attribute (base_entity_name, subtype_entity_name, attribute_name, nullable)
SELECT e.value->>'base_entity' AS base_entity_name
     , e.value->>'name' AS subtype_entity_name
     , c.value->>'name' AS attribute_name
     , (c.value->>'nullable')::boolean AS nullable
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_array_elements(cm.config#>'{entities}') AS e
       
       CROSS JOIN jsonb_array_elements(e.value#>'{attributes}') AS c
 WHERE e.value->>'entity_type_code' = 's';