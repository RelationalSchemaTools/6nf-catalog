CREATE OR REPLACE VIEW meta.table AS
WITH history_cross_join AS (
     SELECT '' AS suffix
          , false AS is_history_table

      UNION ALL

     SELECT '_history' AS suffix
          , true AS is_history_table
)
SELECT ea.schema_name
     , ea.base_entity_name AS entity_name
     , ea.attribute_name
     , ea.data_type AS attribute_data_type
     , CONCAT(ea.base_entity_name,
              CASE WHEN e.entity_type_code = 'r'
                             THEN ''
                        WHEN ea.is_logical_primary_key
                             THEN '__base'
                        ELSE CONCAT('__', ea.attribute_name) END,
              h.suffix
       ) AS table_name
     , e.entity_type_code
     , ea.is_logical_primary_key AS is_base_table
     , ea.is_logical_primary_key AS is_attribute_logical_primary_key
     , ea.referenced_entity AS attribute_references_entity
     , is_history_table
  FROM meta.entity_attribute AS ea
       JOIN meta.entity AS e
       ON ea.base_entity_name = e.entity_name

       CROSS JOIN history_cross_join AS h
 WHERE is_base_level
 ORDER BY schema_name
        , entity_name
        , attribute_name;
