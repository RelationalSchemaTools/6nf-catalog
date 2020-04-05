CREATE OR REPLACE FUNCTION meta.create_foreign_keys() RETURNS VOID AS
$BODY$
BEGIN

    CREATE TEMP TABLE foreign_key_sql ON COMMIT DROP AS
    SELECT ta.schema_name
         , ta.table_name
         , CONCAT('ALTER TABLE ', ta.schema_name, '.', ta.table_name, E'\n',
                  E'\t', 'ADD FOREIGN KEY (', ta.attribute_name, ')', E'\n',
                  E'\t', 'REFERENCES ', t.schema_name, '.', t.table_name, ' (', ta.attribute_name, ');') AS sql_definition
      FROM meta.table_attribute AS ta
           JOIN meta.table AS t
           ON ta.entity_name = t.entity_name
              AND t.is_base_table IS TRUE
              AND t.is_history_table IS FALSE
     WHERE is_db_primary_key IS TRUE
       AND is_identity IS FALSE

     UNION ALL

    SELECT t.schema_name
         , t.table_name
         , CONCAT('ALTER TABLE ', t.schema_name, '.', t.table_name, E'\n',
                  E'\t', 'ADD FOREIGN KEY (', t.attribute_name, ')', E'\n',
                  E'\t', 'REFERENCES ', rt.schema_name, '.', rt.table_name, ' (', rt.attribute_name, ');')
      FROM meta.table AS t
           JOIN meta.entity AS e
           ON t.attribute_references_entity = e.entity_name

           JOIN meta.table AS rt
           ON e.base_entity_name = rt.entity_name
              AND rt.is_attribute_logical_primary_key
              AND rt.is_history_table IS FALSE
     WHERE t.attribute_references_entity IS NOT NULL;

    PERFORM meta.execute_dynamic_sql(sql_definition)
       FROM foreign_key_sql;
    
END;
$BODY$ LANGUAGE PLPGSQL;
