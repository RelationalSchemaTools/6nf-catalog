CREATE OR REPLACE VIEW meta.column AS
SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , CONCAT(t.entity_name, '_dbid') AS column_name
     , t.table_alias
     , 0 AS ordinal_position
     , CASE WHEN is_base_table IS TRUE AND is_history_table IS FALSE
                 THEN 'bigserial'
            ELSE 'bigint'
       END AS data_type
     , is_base_table AND NOT is_history_table AS is_identity
     , true AS is_db_primary_key
     , false AS is_logical_primary_key
     , false AS is_audit_attribute
     , t.is_history_table
     , t.is_base_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , t.attribute_name AS column_name
     , t.table_alias
     , 0 AS ordinal_position
     , attribute_data_type AS data_type
     , false AS is_identity
     , true AS is_db_primary_key
     , true AS is_logical_primary_key
     , false AS is_audit_attribute
     , t.is_history_table
     , t.is_base_table
  FROM meta.table AS t
 WHERE t.entity_type_code = 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , t.attribute_name AS column_name
     , t.table_alias
     , 1 AS ordinal_position
     , t.attribute_data_type AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , t.is_attribute_logical_primary_key AS is_logical_primary_key
     , false AS is_audit_attribute
     , t.is_history_table
     , t.is_base_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , 'name' AS column_name
     , t.table_alias
     , 1 AS ordinal_position
     , 'varchar(255)' AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , false AS is_logical_primary_key
     , false AS is_audit_attribute
     , t.is_history_table
     , t.is_base_table
  FROM meta.table AS t
 WHERE t.entity_type_code = 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , 'is_deleted' AS column_name
     , t.table_alias
     , 2 AS ordinal_position
     , 'boolean' AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , false AS is_logical_primary_key
     , true AS is_audit_attribute
     , t.is_history_table
     , t.is_base_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , 'created_date' AS column_name
     , t.table_alias
     , 3 AS ordinal_position
     , 'timestamp' AS data_type
     , false AS is_identity
     , false AS is_db_primary_key
     , false AS is_logical_primary_key
     , true AS is_audit_attribute
     , t.is_history_table
     , t.is_base_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r'

 UNION ALL

SELECT t.schema_name
     , t.table_name
     , t.entity_name
     , t.attribute_name
     , 'modified_date' AS column_name
     , t.table_alias
     , 4 AS ordinal_position
     , 'timestamp' AS data_type
     , false AS is_identity
     , is_history_table AS is_db_primary_key
     , false AS is_logical_primary_key
     , true AS is_audit_attribute
     , t.is_history_table
     , t.is_base_table
  FROM meta.table AS t
 WHERE t.entity_type_code <> 'r';

