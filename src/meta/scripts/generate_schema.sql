BEGIN TRANSACTION;
    DO $$
    BEGIN
        PERFORM meta.create_schemas();
    END$$;
COMMIT;

BEGIN TRANSACTION;
    DO $$
    BEGIN
        PERFORM meta.create_tables();
    END$$;
COMMIT;

BEGIN TRANSACTION;
    DO $$
    BEGIN
        PERFORM meta.create_primary_keys();
    END$$;
COMMIT;

BEGIN TRANSACTION;
    DO $$
    BEGIN
        PERFORM meta.create_unique_indices();
    END$$;
COMMIT;

BEGIN TRANSACTION;
    DO $$
    BEGIN
        PERFORM meta.create_foreign_keys();
    END$$;
COMMIT;