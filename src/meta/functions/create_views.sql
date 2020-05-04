CREATE OR REPLACE FUNCTION meta.create_views() RETURNS VOID AS
$BODY$
BEGIN
    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE OR REPLACE VIEW ', ea.schema_name, '.', ea.entity_name, '_v1', ' AS', E'\n',
                       'SELECT ',
                       STRING_AGG(CONCAT(c.table_alias, '.', c.attribute_name), E'\n     , ' ORDER BY ea.ordinal_position), E'\n',
                       '     , base.created_date', E'\n',
                       '     , base.modified_date', E'\n',
                       STRING_AGG(CASE WHEN c.is_base_table IS TRUE
                                            THEN CONCAT('  FROM ', c.schema_name, '.', c.table_name, ' AS ', c.table_alias)
                                       ELSE CONCAT(CASE WHEN ea.is_nullable THEN 'LEFT ' END,
                                                   '       JOIN ', c.schema_name, '.', c.table_name, ' AS ', c.table_alias, E'\n',
                                                   '       ON base.', c.column_name, ' = ', c.table_alias, '.', c.column_name, E'\n',
                                                   '          AND ', c.table_alias, '.is_deleted IS FALSE', E'\n')
                                  END, E'\n' ORDER BY ea.ordinal_position),
                       ' WHERE base.is_deleted IS FALSE;')
            )
       FROM meta.entity AS e
            JOIN meta.entity_attribute AS ea
            ON e.schema_name = ea.schema_name
               AND e.entity_name = ea.entity_name

            LEFT JOIN meta.column AS c
            ON ea.schema_name = c.schema_name
               AND ea.base_entity_name = c.entity_name
               AND ea.attribute_name = c.attribute_name
               AND c.is_db_primary_key IS TRUE
               AND c.is_history_table IS FALSE
      WHERE e.entity_type_code <> 'r'
      GROUP BY ea.schema_name
             , ea.entity_name;
END;
$BODY$ LANGUAGE PLPGSQL;