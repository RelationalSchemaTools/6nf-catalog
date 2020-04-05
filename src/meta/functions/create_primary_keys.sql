CREATE OR REPLACE FUNCTION meta.create_primary_keys() RETURNS VOID AS
$BODY$
BEGIN
    PERFORM meta.execute_dynamic_sql(
                CONCAT('ALTER TABLE ', schema_name, '.', table_name, E'\n',
                       E'\t', 'ADD PRIMARY KEY (', STRING_AGG(attribute_name, ', ' ORDER BY ordinal_position), ');')
            )
       FROM meta.table_attribute
      WHERE is_db_primary_key IS TRUE
      GROUP BY schema_name
             , table_name;
END;
$BODY$ LANGUAGE PLPGSQL;

