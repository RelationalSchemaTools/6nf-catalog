CREATE OR REPLACE FUNCTION meta.execute_dynamic_sql(_sql text, _print_sql_code char(1) DEFAULT 'E') RETURNS void AS
$BODY$
BEGIN
    IF _sql IS NULL
    THEN
        RETURN;
    END IF;

    IF _print_sql_code IN ('B', '?')
    THEN
        RAISE NOTICE '%', _sql;
    END IF;

    IF _print_sql_code IN ('?')
    THEN
        RETURN;
    END IF;

    BEGIN
        EXECUTE _sql;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '%', _sql;
        RAISE EXCEPTION '% %', SQLERRM, SQLSTATE;
    END;
END;
$BODY$ LANGUAGE PLPGSQL;