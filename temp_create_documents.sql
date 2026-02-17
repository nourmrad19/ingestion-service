CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.documents (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id uuid NOT NULL,
    uploaded_by uuid,
    created_by uuid,
    updated_by uuid,
    filename varchar(255) NOT NULL,
    storage_path varchar(500) NOT NULL,
    file_size integer,
    mime_type varchar(100),
    language varchar(10),
    status varchar(50) NOT NULL DEFAULT 'pending',
    metadata_json jsonb DEFAULT '{}'::jsonb,
    is_deleted boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_documents_tenant_id ON documents(tenant_id);
CREATE INDEX IF NOT EXISTS ix_documents_uploaded_by ON documents(uploaded_by);
CREATE INDEX IF NOT EXISTS ix_documents_language ON documents(language);
CREATE INDEX IF NOT EXISTS ix_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS ix_documents_created_at ON documents(created_at);

DO $$ BEGIN
 IF NOT EXISTS (
   SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE c.relname = 'ix_documents_is_deleted'
 ) THEN
   CREATE INDEX ix_documents_is_deleted ON documents(is_deleted) WHERE is_deleted = false;
 END IF;
END $$;
