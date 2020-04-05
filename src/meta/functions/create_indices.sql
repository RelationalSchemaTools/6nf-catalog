CREATE OR REPLACE FUNCTION meta.create_indices() RETURNS VOID AS
$BODY$
BEGIN
    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE INDEX ', E'\n',
                       E'\t', 'ON ', ta.schema_name, '.', ta.table_name, E'\n',
                       E'\t', 'USING btree (', ta.attribute_name, ');')
            )
       FROM meta.table_attribute AS ta
            JOIN meta.table_attribute AS _ta
            ON ta.schema_name = _ta.schema_name
               AND ta.entity_name = _ta.entity_name
               AND ta.attribute_name = _ta.attribute_name
      WHERE ta.is_history_table IS TRUE
        AND _ta.is_history_table IS FALSE
        AND _ta.is_identity
        AND _ta.is_db_primary_key IS TRUE;
END;
$BODY$ LANGUAGE PLPGSQL;
