CREATE OR REPLACE FUNCTION meta.create_schemas() RETURNS VOID AS
$BODY$
BEGIN
    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE SCHEMA ', schema_name, ';')
            )
       FROM meta.schema;
END;
$BODY$ LANGUAGE PLPGSQL;
