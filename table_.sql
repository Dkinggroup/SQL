DO $$
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO table_ (status) VALUES (false);
    END LOOP;
END;
$$;
