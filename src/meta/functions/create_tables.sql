CREATE OR REPLACE FUNCTION meta.create_tables() RETURNS VOID AS
$BODY$
BEGIN
    CREATE TEMP TABLE attribute_agg ON COMMIT DROP AS
    SELECT schema_name
         , table_name
         , STRING_AGG(CONCAT(column_name, ' ', data_type, ' NOT NULL'), E'\n,\t' ORDER BY ordinal_position) AS attributes_definition
      FROM meta.column
     GROUP BY schema_name
            , table_name;

    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE TABLE ',t.schema_name, '.', t.table_name, ' (', E'\n',
                       E'\t', a.attributes_definition, E'\n',
                       ');'
                       )
            )
       FROM meta.table AS t
            JOIN attribute_agg AS a
            ON t.schema_name = a.schema_name
               AND t.table_name = a.table_name;
END;
$BODY$ LANGUAGE PLPGSQL;
