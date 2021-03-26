CREATE OR REPLACE VIEW meta.entity_attribute AS
SELECT e.schema_name
     , e.base_entity_name
     , e.entity_name
     , CONCAT(e.base_entity_name, '_id') AS attribute_name
     , et.primary_key_data_type AS data_type
     , 1 AS ordinal_position
     , false AS is_nullable
     , e.entity_type_code = 's' AS is_subtype_attribute
     , e.entity_type_code <> 's' AS is_base_level
     , true AS is_logical_primary_key
     , null AS referenced_entity
  FROM meta.entity AS e
       JOIN meta.entity_type AS et
       ON e.entity_type_code = et.entity_type_code

 UNION ALL

SELECT schema_name
     , entity_name AS base_entity_name
     , entity_name
     , attribute_name
     , data_type
     , ordinal_position + 10 AS ordinal_position
     , is_nullable
     , is_subtype_attribute
     , true AS is_base_level
     , false AS is_logical_primary_key
     , referenced_entity
  FROM meta.base_entity_attribute

 UNION ALL

SELECT bea.schema_name
     , bea.entity_name AS base_entity_name
     , e.entity_name
     , bea.attribute_name
     , bea.data_type
     , bea.ordinal_position + 10 AS ordinal_position
     , bea.is_nullable
     , bea.is_subtype_attribute
     , false AS is_base_level
     , false AS is_logical_primary_key
     , bea.referenced_entity
  FROM meta.base_entity_attribute AS bea
       JOIN meta.entity AS e
       ON bea.entity_name = e.base_entity_name
 WHERE e.entity_type_code = 's'
   AND bea.is_subtype_attribute IS FALSE

 UNION ALL

SELECT sea.schema_name
     , sea.base_entity_name
     , sea.subtype_entity_name AS entity_name
     , sea.attribute_name
     , bea.data_type
     , bea.ordinal_position + 10 AS ordinal_position
     , sea.is_nullable
     , true AS is_subtype_attribute
     , false AS is_base_level
     , false AS is_logical_primary_key
     , bea.referenced_entity
  FROM meta.subtype_entity_attribute AS sea
       JOIN meta.base_entity_attribute AS bea
       ON sea.schema_name = bea.schema_name
          AND sea.base_entity_name = bea.entity_name
          AND sea.attribute_name = bea.attribute_name

 UNION ALL

SELECT ce.schema_name
     , ce.base_entity_name
     , per.child_entity_name AS entity_name
     , CONCAT(pe.entity_name, '_id') AS attribute_name
     , pet.primary_key_data_type AS data_type
     , 2 AS ordinal_position
     , false AS is_nullable
     , ce.entity_type_code = 's' AS is_subtype_attribute
     , ce.entity_type_code <> 's' AS is_base_level
     , false AS is_logical_primary_key
     , per.parent_entity_name AS referenced_entity
  FROM meta.parent_entity_relationship AS per
       JOIN meta.entity AS ce
       ON per.child_entity_name = ce.entity_name

       JOIN meta.entity AS pe
       ON per.parent_entity_name = pe.entity_name

       JOIN meta.entity_type AS pet
       ON pe.entity_type_code = pet.entity_type_code

 UNION ALL

SELECT ce.schema_name
     , ce.base_entity_name
     , ce.base_entity_name AS entity_name
     , CONCAT(pe.entity_name, '_id') AS attribute_name
     , pet.primary_key_data_type AS data_type
     , 2 AS ordinal_position
     , false AS is_nullable
     , true AS is_subtype_attribute
     , true AS is_base_level
     , false AS is_logical_primary_key
     , per.parent_entity_name AS referenced_entity
  FROM meta.parent_entity_relationship AS per
       JOIN meta.entity AS ce
       ON per.child_entity_name = ce.entity_name

       JOIN meta.entity AS pe
       ON per.parent_entity_name = pe.entity_name

       JOIN meta.entity_type AS pet
       ON pe.entity_type_code = pet.entity_type_code
 WHERE ce.entity_type_code = 's';