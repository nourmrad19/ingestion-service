DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname='alembic_version') THEN
    CREATE TABLE alembic_version (version_num VARCHAR(32) NOT NULL);
    INSERT INTO alembic_version (version_num) VALUES ('001_initial');
  ELSE
    IF NOT EXISTS (SELECT 1 FROM alembic_version WHERE version_num='001_initial') THEN
      INSERT INTO alembic_version (version_num) VALUES ('001_initial');
    END IF;
  END IF;
END
$$;
