CREATE OR REPLACE FUNCTION meta.create_insert_triggers() RETURNS VOID AS
$BODY$
BEGIN
    PERFORM meta.execute_dynamic_sql(
                CONCAT('CREATE TRIGGER ', e.entity_name, '_v1_insert', E'\n',
                  E'\t', 'INSTEAD OF INSERT', E'\n',
                  E'\t', 'ON ', e.schema_name, '.', e.entity_name, '_v1', E'\n',
                  E'\t', 'FOR EACH ROW', E'\n',
                  E'\t', 'EXECUTE PROCEDURE ', e.schema_name, '.', e.entity_name, '_v1_insert_trigger_function();')
            )
       FROM meta.entity AS e
      WHERE e.entity_type_code IN ('b', 's');
END;
$BODY$ LANGUAGE PLPGSQL;