CREATE OR REPLACE FUNCTION meta.create_unique_indices() RETURNS VOID AS
$BODY$
BEGIN
    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE UNIQUE INDEX ', E'\n', --table_name, '__', attribute_name, '_ux', E'\n',
                       E'\t', 'ON ', schema_name, '.', table_name, E'\n',
                        E'\t', 'USING btree (', column_name, ');')
            )
       FROM meta.column
      WHERE is_logical_primary_key IS TRUE
        AND is_db_primary_key IS FALSE;
END;
$BODY$ LANGUAGE PLPGSQL;
