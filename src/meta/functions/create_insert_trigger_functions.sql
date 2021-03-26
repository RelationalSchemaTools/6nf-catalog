CREATE OR REPLACE FUNCTION meta.create_insert_trigger_functions() RETURNS VOID AS
$BODY$
BEGIN
    CREATE TEMP TABLE insert_agg ON COMMIT DROP AS
    SELECT c.schema_name
         , c.table_name
         , c.entity_name
         , c.attribute_name
         , CONCAT(E'\t', 'INSERT INTO ', c.schema_name, '.', c.table_name, ' (',
                  STRING_AGG(c.column_name, ', ' ORDER BY c.ordinal_position), ')', E'\n',
                  E'\t', 'SELECT ',
                  STRING_AGG(CASE WHEN c.attribute_name = c.column_name
                                       THEN CONCAT('NEW.', c.column_name)
                                  WHEN c.is_db_primary_key
                                       THEN CONCAT('_', c.column_name)
                                  WHEN c.column_name = 'is_deleted'
                                       THEN 'FALSE'
                                  WHEN c.is_audit_attribute
                                       THEN '_timestamp'
                             END, E'\n\t     , ' ORDER BY c.ordinal_position),
                  STRING_AGG(CASE WHEN c.is_logical_primary_key IS TRUE
                                       THEN CONCAT(E'\n',
                                                   E'\t', '    ON CONFLICT (', c.column_name, ')', E'\n',
                                                   -- TODO: Update instead of just insert
                                                   E'\t', '    DO NOTHING', E'\n',
                                                   E'\t', '       RETURNING ', _c.column_name, ' INTO _', _c.column_name, ';', E'\n',
                                                   E'\n',
                                                   E'\t', 'IF _', _c.column_name, ' IS NULL THEN', E'\n',
                                                   E'\t', E'\t', 'RETURN NEW;', E'\n',
                                                   E'\t', 'END IF')
                             END, '' ORDER BY c.ordinal_position), ';') AS insert_definition
      FROM meta.column AS c
           JOIN meta.column AS _c
           ON c.schema_name = _c.schema_name
              AND c.table_name = _c.table_name
              AND _c.is_db_primary_key
              AND _c.is_history_table IS FALSE
     WHERE c.is_identity IS FALSE
     GROUP BY c.schema_name
            , c.table_name
            , c.entity_name
            , c.attribute_name;
    
    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE OR REPLACE FUNCTION ', e.schema_name, '.', e.entity_name, '_v1_insert_trigger_function()', E'\n',
                       E'\t', 'RETURNS trigger AS', E'\n',
                       chr(36), 'BODY', chr(36), E'\n',
                       'DECLARE', E'\n',
                       E'\t', '_', c.column_name, ' BIGINT;', E'\n',
                       E'\t', '_timestamp timestamp;', E'\n',
                       'BEGIN', E'\n',
                       E'\t', '_timestamp := now();', E'\n',
                       E'\n',
                       STRING_AGG(ia.insert_definition, E'\n\n' ORDER BY ea.ordinal_position), E'\n',
                       E'\n',
                       E'\t', 'RETURN NEW;', E'\n',
                       'END;', E'\n',
                       chr(36), 'BODY', chr(36), ' LANGUAGE plpgsql', E'\n',
                       '       SECURITY DEFINER;')
            )
       FROM meta.entity AS e
            JOIN meta.entity_attribute AS ea
            ON e.schema_name = ea.schema_name
               AND e.entity_name = ea.entity_name

            JOIN insert_agg AS ia
            ON ea.schema_name = ia.schema_name
               AND ea.base_entity_name = ia.entity_name
               AND ea.attribute_name = ia.attribute_name

            JOIN meta.column AS c
            ON e.schema_name = c.schema_name
               AND e.base_entity_name = c.entity_name
               AND c.is_db_primary_key IS TRUE
               AND c.is_history_table IS FALSE
               AND c.is_base_table IS TRUE
      GROUP BY e.schema_name
             , e.entity_name
             , c.column_name;
END;
$BODY$ LANGUAGE PLPGSQL;