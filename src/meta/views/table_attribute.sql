CREATE OR REPLACE VIEW meta.table_attribute AS
SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , CONCAT(t.entity_name, '_dbid') AS attribute_name
     , 0 AS ordinal_position
     , 'bigint' AS data_type
     , is_base_table AND NOT is_history_table AS is_identity
     , true AS is_db_primary_key
     , false AS is_logical_primary_key
     , t.is_history_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , 0 AS ordinal_position
     , attribute_data_type AS data_type
     , false AS is_identity
     , true AS is_db_primary_key
     , true AS is_logical_primary_key
     , t.is_history_table
  FROM meta.table AS t
 WHERE t.entity_type_code = 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , 1 AS ordinal_position
     , t.attribute_data_type AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , t.is_attribute_logical_primary_key AS is_logical_primary_key
     , t.is_history_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , 'name' AS attribute_name
     , 1 AS ordinal_position
     , 'varchar(255)' AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , false AS is_logical_primary_key
     , t.is_history_table
  FROM meta.table AS t
 WHERE t.entity_type_code = 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , 'is_deleted' AS attribute_name
     , 2 AS ordinal_position
     , 'boolean' AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , false AS is_logical_primary_key
     , t.is_history_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , 'created_date' AS attribute_name
     , 3 AS ordinal_position
     , 'timestamp' AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , false AS is_logical_primary_key
     , t.is_history_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , 'modified_date' AS attribute_name
     , 4 AS ordinal_position
     , 'timestamp' AS data_type
     , false AS is_identity
     , is_history_table AS is_db_primary_key
     , false AS is_logical_primary_key
     , t.is_history_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r';

