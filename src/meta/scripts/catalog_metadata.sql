-- entity_type
INSERT INTO meta.entity_type (entity_type_code, name, primary_key_data_type)
VALUES ('b', 'Base', 'uuid')
,      ('ba', 'Abstract Base', 'uuid')
,      ('s', 'Subtype', 'uuid')
,      ('r', 'Reference List', 'smallint');


-- schema
INSERT INTO meta.schema(schema_name)
SELECT s.name AS schema_name
  FROM meta.catalog_metadata as cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58));


-- entity
INSERT INTO meta.entity(schema_name, entity_name, base_entity_name, entity_type_code)
SELECT s.name AS schema_name
     , e.name AS entity_name
     , e.name AS base_entity_name
     , CASE WHEN subtype_entities IS NULL
                 THEN 'b'
            ELSE 'ba'
       END AS entity_type_code
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), subtype_entities jsonb)

 UNION ALL

SELECT s.name AS schema_name
     , st.name AS entity_name
     , e.name AS base_entity_name
     , 's' AS entity_type_code
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), subtype_entities jsonb)

       CROSS JOIN jsonb_to_recordset(e.subtype_entities)
       AS st(name varchar(58))

 UNION ALL

SELECT s.name AS schema_name
     , re.name AS entity_name
     , re.name AS base_entity_name
     , 'r' AS entity_type_code
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), reference_entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.reference_entities)
       AS re(name varchar(58));


-- base_entity_attribute
INSERT INTO meta.base_entity_attribute (schema_name, entity_name, attribute_name, data_type, ordinal_position, is_nullable, is_subtype_attribute, referenced_entity)
SELECT s.name AS schema_name
     , e.name AS entity_name
     , a.name AS attribute_name
     , COALESCE(_et.primary_key_data_type, a.data_type) AS data_type
     , a.ordinal_position
     , a.nullable AS is_nullable
     , false AS is_subtype_attribute
     , a.references AS referenced_entity
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), attributes jsonb)

       CROSS JOIN jsonb_to_recordset(e.attributes)
       AS a(name varchar(61), data_type varchar(30), ordinal_position smallint, nullable boolean, "references" varchar(58))

       LEFT JOIN meta.entity _e
       ON a.references = _e.entity_name

       LEFT JOIN meta.entity_type _et
       ON _e.entity_type_code = _et.entity_type_code

 UNION ALL

SELECT s.name AS schema_name
     , e.name AS entity_name
     , sa.name AS attribute_name
     , COALESCE(_et.primary_key_data_type, sa.data_type) AS data_type
     , sa.ordinal_position
     , true AS is_nullable
     , true AS is_subtype_attribute
     , sa.references AS referenced_entity
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), subtype_attributes jsonb)

       CROSS JOIN jsonb_to_recordset(e.subtype_attributes)
       AS sa(name varchar(61), data_type varchar(30), ordinal_position smallint, "references" varchar(58))

       LEFT JOIN meta.entity _e
       ON sa.references = _e.entity_name

       LEFT JOIN meta.entity_type _et
       ON _e.entity_type_code = _et.entity_type_code;


-- subtype_entity_attribute
INSERT INTO meta.subtype_entity_attribute (schema_name, base_entity_name, subtype_entity_name, attribute_name, is_nullable)
SELECT s.name AS schema_name
     , e.name AS base_entity_name
     , st.name AS subtype_entity_name
     , a.name AS attribute_name
     , a.nullable AS is_nullable
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), subtype_entities jsonb)
       
       CROSS JOIN jsonb_to_recordset(e.subtype_entities)
       AS st(name varchar(58), attributes jsonb)

       CROSS JOIN jsonb_to_recordset(st.attributes)
       AS a(name varchar(58), nullable boolean);


-- parent_entity_relationship
INSERT INTO meta.parent_entity_relationship (parent_entity_name, child_entity_name)
SELECT e.parent_entity AS parent_entity_name
     , e.name AS entity_name
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), parent_entity varchar(58))
 WHERE e.parent_entity IS NOT NULL

 UNION ALL

SELECT st.parent_entity AS parent_entity_name
     , st.name AS entity_name
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), parent_entity varchar(58), subtype_entities jsonb)

       CROSS JOIN jsonb_to_recordset(e.subtype_entities)
       AS st(name varchar(58), parent_entity varchar(58))
 WHERE st.parent_entity IS NOT NULL;


-- referenced_entity_relationship
INSERT INTO meta.referenced_entity_relationship (referencing_entity_name, referenced_entity_name, referencing_entity_attribute_name)
SELECT e.name AS referencing_entity_name
     , a.references AS referenced_entity_name
     , a.name AS referencing_entity_attribute_name
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), parent_entity varchar(58), attributes jsonb)

       CROSS JOIN jsonb_to_recordset(e.attributes)
       AS a(name varchar(58), "references" varchar(58))
 WHERE a.references IS NOT NULL

 UNION ALL

SELECT e.name AS referencing_entity_name
     , sa.references AS referenced_entity_name
     , sa.name AS referencing_entity_attribute_name
  FROM meta.catalog_metadata AS cm
       CROSS JOIN jsonb_to_recordset(cm.config#>'{schemas}')
       AS s(name varchar(58), entities jsonb)

       CROSS JOIN jsonb_to_recordset(s.entities)
       AS e(name varchar(58), parent_entity varchar(58), subtype_attributes jsonb)

       CROSS JOIN jsonb_to_recordset(e.subtype_attributes)
       AS sa(name varchar(58), "references" varchar(58))
 WHERE sa.references IS NOT NULL;