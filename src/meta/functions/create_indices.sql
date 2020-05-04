CREATE OR REPLACE FUNCTION meta.create_indices() RETURNS VOID AS
$BODY$
BEGIN
    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE INDEX ', E'\n',
                       E'\t', 'ON ', c.schema_name, '.', c.table_name, E'\n',
                       E'\t', 'USING btree (', c.column_name, ');')
            )
       FROM meta.column AS c
            JOIN meta.column AS _c
            ON c.schema_name = _c.schema_name
               AND c.entity_name = _c.entity_name
               AND c.column_name = _c.column_name
      WHERE c.is_history_table IS TRUE
        AND _c.is_history_table IS FALSE
        AND _c.is_identity
        AND _c.is_db_primary_key IS TRUE;
END;
$BODY$ LANGUAGE PLPGSQL;
