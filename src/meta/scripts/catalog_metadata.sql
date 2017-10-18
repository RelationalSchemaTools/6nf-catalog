-- entity_type
INSERT INTO meta.entity_type (entity_type_code, name, primary_key_data_type)
VALUES ('b', 'Base', 'uuid')
,      ('ba', 'Abstract Base', 'uuid')
,      ('s', 'Subtype', 'uuid')
,      ('r', 'Reference List', 'smallint');


-- entity
INSERT INTO meta.entity (entity_name, entity_type_code)
SELECT e.name AS entity_name
     , e.entity_type_code
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{entities}') AS e(name varchar(58), entity_type_code char(2));


-- base_entity_attribute
INSERT INTO meta.base_entity_attribute (entity_name, attribute_name, data_type, ordinal_position, nullable, is_subtype_attribute)
SELECT e.name AS entity_name
     , a.name AS attribute_name
     , COALESCE(_et.primary_key_data_type, a.data_type) AS data_type
     , a.ordinal_position
     , a.nullable
     , false AS is_subtype_attribute
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{entities}') AS e(name varchar(58), entity_type_code char(2), attributes jsonb)
       
       CROSS JOIN jsonb_to_recordset(e.attributes) AS a(name varchar(61), data_type varchar(30), ordinal_position smallint, nullable boolean, "references" varchar(58))
       
       LEFT JOIN meta.entity _e
       ON a.references = _e.entity_name
       
       LEFT JOIN meta.entity_type _et
       ON _e.entity_type_code = _et.entity_type_code
 WHERE e.entity_type_code IN ('b', 'ba')
 
 UNION ALL

SELECT e.name AS entity_name
     , a.name AS attribute_name
     , COALESCE(_et.primary_key_data_type, a.data_type) AS data_type
     , a.ordinal_position
     , true AS nullable
     , false AS is_subtype_attribute
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{entities}') AS e(name varchar(58), entity_type_code char(2), subtype_attributes jsonb)
       
       CROSS JOIN jsonb_to_recordset(e.subtype_attributes) AS a(name varchar(61), data_type varchar(30), ordinal_position smallint, nullable boolean, "references" varchar(58))
       
       LEFT JOIN meta.entity _e
       ON a.references = _e.entity_name
       
       LEFT JOIN meta.entity_type _et
       ON _e.entity_type_code = _et.entity_type_code
 WHERE e.entity_type_code IN ('b', 'ba');


-- subtype_entity_attribute
INSERT INTO meta.subtype_entity_attribute (base_entity_name, subtype_entity_name, attribute_name, nullable)
SELECT e.base_entity AS base_entity_name
     , e.name AS subtype_entity_name
     , a.name AS attribute_name
     , a.nullable
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{entities}') AS e(base_entity varchar(58), name varchar(58), entity_type_code char(2), attributes jsonb)
       
       CROSS JOIN jsonb_to_recordset(e.attributes) AS a(name varchar(61), nullable boolean)
 WHERE e.entity_type_code = 's';


-- parent_entity_relationship
INSERT INTO meta.parent_entity_relationship (parent_entity_name, child_entity_name)
SELECT e.parent_entity AS parent_entity_name
     , e.name AS child_entity_name
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{entities}') AS e(parent_entity varchar(58), name varchar(58))
 WHERE e.parent_entity IS NOT NULL;


-- referenced_entity_relationship
INSERT INTO meta.referenced_entity_relationship (referencing_entity_name, referenced_entity_name, referencing_entity_attribute_name)
SELECT e.name AS referencing_entity_name
     , a.references AS referenced_entity_name
     , a.name AS referencing_entity_attribute_name
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{entities}') AS e(name varchar(58), entity_type_code char(2), attributes jsonb)
       
       CROSS JOIN jsonb_to_recordset(e.attributes) AS a(name varchar(61), "references" varchar(58))
 WHERE e.entity_type_code IN ('b', 'ba')
   AND a.references IS NOT NULL
 
 UNION ALL

SELECT e.name AS referencing_entity_name
     , a.references AS referenced_entity_name
     , a.name AS referencing_entity_attribute_name
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{entities}') AS e(name varchar(58), entity_type_code char(2), subtype_attributes jsonb)
       
       CROSS JOIN jsonb_to_recordset(e.subtype_attributes) AS a(name varchar(61), "references" varchar(58))
 WHERE e.entity_type_code IN ('b', 'ba')
   AND a.references IS NOT NULL;