# Updated Models - Modern SQLAlchemy 2.0 Architecture

## What Changed

Your models have been upgraded to use **modern SQLAlchemy 2.0** with the following improvements:

### Old Approach (Flask-SQLAlchemy with Integer IDs)
```python
from app.database import db

class Document(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
```

### New Approach (SQLAlchemy 2.0 with UUID and Audit Fields)
```python
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID, JSONB

class Base(DeclarativeBase):
    pass

class Document(Base):
    __tablename__ = "documents"
    
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        server_default=text("uuid_generate_v4()")
    )
```

---

## New Document Model Structure

### Core Identifiers (UUIDs)
| Column | Type | Purpose |
|--------|------|---------|
| `id` | UUID | Primary key (auto-generated server-side) |
| `tenant_id` | UUID | Multi-tenancy support (which organization owns this) |
| `uploaded_by` | UUID | Nullable - user who uploaded the document |
| `created_by` | UUID | Nullable - user who created the record |
| `updated_by` | UUID | Nullable - user who last updated the record |

### File Information
| Column | Type | Purpose |
|--------|------|---------|
| `filename` | String(255) | Original filename |
| `storage_path` | String(500) | Path where file is stored (S3, MinIO, etc.) |
| `file_size` | Integer | Nullable - size in bytes |
| `mime_type` | String(100) | Nullable - e.g., "application/pdf" |
| `language` | String(10) | Nullable - detected language code (en, fr, etc.) - **indexed** |

### Status & Metadata
| Column | Type | Purpose |
|--------|------|---------|
| `status` | String(50) | "pending", "processing", "completed", "failed" - **indexed** |
| `metadata_json` | JSONB | JSON data (default: empty `{}`) - **flexible schema** |
| `is_deleted` | Boolean | Soft delete flag - **partial index** |

### Timestamps
| Column | Type | Purpose |
|--------|------|---------|
| `created_at` | DateTime(tz) | When record was created - **indexed** |
| `updated_at` | DateTime(tz) | When record was last updated |

---

## Key Features

### 1. **UUID Primary Key (Not Integer)**
**Why?**
- Globally unique across microservices
- Prevents ID enumeration attacks
- Better for distributed systems
- Auto-generated on database side with `uuid_generate_v4()`

```python
id: Mapped[uuid.UUID] = mapped_column(
    UUID(as_uuid=True),
    primary_key=True,
    server_default=text("uuid_generate_v4()")
)
```

### 2. **Multi-Tenancy Support**
Every document belongs to a `tenant_id`, enabling database-level isolation:

```python
tenant_id: Mapped[uuid.UUID] = mapped_column(
    UUID(as_uuid=True), 
    nullable=False, 
    index=True  # Indexed for fast queries
)
```

Query example:
```python
# Get all documents for a tenant
docs = session.query(Document).filter_by(tenant_id=tenant_id).all()
```

### 3. **Audit Trail**
Track who created/updated documents:

```python
created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
updated_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
```

### 4. **JSONB for Flexible Metadata**
Store arbitrary JSON data without schema changes:

```python
metadata_json: Mapped[dict] = mapped_column(
    JSONB, 
    server_default=text("'{}'::jsonb")
)
```

Example usage:
```python
doc = Document(
    filename="report.pdf",
    metadata_json={
        "pages": 15,
        "author": "John Doe",
        "keywords": ["report", "analysis"],
        "custom_field": "any value"
    }
)
```

Query JSONB:
```sql
-- Get documents with metadata.pages > 10
SELECT * FROM documents WHERE metadata_json->>'pages' > '10';
```

### 5. **Soft Deletes with Partial Index**
Don't actually delete - just mark as deleted:

```python
is_deleted: Mapped[bool] = mapped_column(
    Boolean, 
    nullable=False, 
    server_default=text("false")
)

__table_args__ = (
    Index(
        "ix_documents_is_deleted",
        "is_deleted",
        postgresql_where=(is_deleted == False)  # Only index non-deleted
    ),
)
```

Benefits:
- Recover accidentally deleted documents
- Audit trail preserved
- Partial index = smaller, faster queries (only 1 value instead of 2)

Query:
```python
# Only get non-deleted documents
docs = session.query(Document).filter_by(is_deleted=False).all()
```

### 6. **Modern Type Hints (SQLAlchemy 2.0)**
Using Python type annotations:

```python
# Old style
created_at = db.Column(db.DateTime, nullable=False)

# New style
created_at: Mapped[datetime] = mapped_column(
    DateTime(timezone=True),
    nullable=False,
    server_default=text('now()')
)
```

Benefits:
- IDE autocomplete works better
- Type checking by Pylance/mypy
- Self-documenting code

---

## Migration Details

The Alembic migration (`001_initial.py`) creates:

1. **UUID Extension** - PostgreSQL adds UUID support:
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp"
   ```

2. **Documents Table** - With all columns defined above

3. **Indexes** for performance:
   - `ix_documents_tenant_id` - Fast tenant filtering
   - `ix_documents_uploaded_by` - Find docs by uploader
   - `ix_documents_language` - Filter by language
   - `ix_documents_status` - Filter by processing status
   - `ix_documents_created_at` - Range queries on creation date
   - `ix_documents_is_deleted` - Partial index for non-deleted only

---

## Database Architecture Overview

```
PostgreSQL Database (mydatabase)
│
└─ documents table
   ├─ id (UUID, PK) - Auto-generated
   ├─ tenant_id (UUID, indexed) - Multi-tenancy
   ├─ uploaded_by (UUID, indexed) - Audit trail
   ├─ created_by (UUID) - Audit trail
   ├─ updated_by (UUID) - Audit trail
   ├─ filename (String)
   ├─ storage_path (String)
   ├─ file_size (Integer)
   ├─ mime_type (String)
   ├─ language (String, indexed)
   ├─ status (String, indexed) - Default: "pending"
   ├─ metadata_json (JSONB) - Flexible schema
   ├─ is_deleted (Boolean) - Soft delete
   ├─ created_at (DateTime, indexed)
   └─ updated_at (DateTime)
```

---

## How to Use in Python Code

### 1. Import the Model
```python
from app.models import Document
from app.database import db_session, Base
from datetime import datetime, timezone
import uuid

session = db_session  # SQLAlchemy Session
```

### 2. Create a New Document
```python
tenant_id = uuid.uuid4()
user_id = uuid.uuid4()

new_doc = Document(
    id=None,  # Auto-generated
    tenant_id=tenant_id,
    uploaded_by=user_id,
    created_by=user_id,
    filename="report.pdf",
    storage_path="s3://bucket/report.pdf",
    file_size=102400,
    mime_type="application/pdf",
    language="en",
    status="pending",
    metadata_json={"pages": 10, "author": "John"}
)

session.add(new_doc)
session.commit()
print(f"Created document: {new_doc.id}")  # UUID
```

### 3. Query Documents
```python
# Get all documents for a tenant
docs = session.query(Document).filter_by(
    tenant_id=tenant_id,
    is_deleted=False
).all()

# Get by ID
doc = session.query(Document).filter_by(id=document_id).first()

# Filter by status
pending_docs = session.query(Document).filter(
    Document.status == "pending",
    Document.is_deleted == False
).all()

# Filter by language
english_docs = session.query(Document).filter_by(
    language="en",
    is_deleted=False
).all()
```

### 4. Update a Document
```python
doc = session.query(Document).filter_by(id=document_id).first()
if doc:
    doc.status = "completed"
    doc.updated_by = user_id
    doc.metadata_json = {"pages": 10, "processed": True}
    session.commit()
```

### 5. Soft Delete (Don't Delete, Mark as Deleted)
```python
doc = session.query(Document).filter_by(id=document_id).first()
if doc:
    doc.is_deleted = True
    doc.updated_by = user_id
    session.commit()
    # Document still exists in DB, just marked as deleted
```

### 6. Query JSONB
```python
# Get documents where metadata contains specific key
from sqlalchemy import JSON

docs = session.query(Document).filter(
    Document.metadata_json["pages"].astext.cast(int) > 5
).all()
```

---

## Benefits of This Architecture

| Feature | Benefit |
|---------|---------|
| **UUID** | Unique across services, no ID leaking, distributed-friendly |
| **Tenant ID** | Multi-tenancy support, data isolation |
| **Audit Fields** | Track who did what, compliance ready |
| **JSONB** | Flexible schema, no migrations for metadata |
| **Soft Deletes** | Recover data, maintain history |
| **Indexed Columns** | Fast queries for common filters |
| **Timestamps** | Track when records change |
| **Type Hints** | Better IDE support, fewer bugs |

---

## Running Migrations

```bash
# Apply all pending migrations
alembic upgrade head

# View applied migrations
alembic history

# Check current version
alembic current
```

## Verifying in pgAdmin

1. Open http://localhost:5050
2. Connect to PostgreSQL server
3. Navigate: Servers → mydatabase → Schemas → public → Tables
4. Right-click "documents" → View/Edit Data
5. You should see empty documents table with all the new columns

---

## Next Steps

1. ✅ Models updated to modern SQLAlchemy 2.0
2. ✅ Migration created with UUID schema
3. ✅ Flexible JSONB metadata support
4. ⏭️ Run: `alembic upgrade head` to create tables
5. ⏭️ View in pgAdmin to confirm table structure
6. ⏭️ Start using the Document model in your code

---

## Troubleshooting

### ImportError: cannot import name 'Document'
- Make sure `app/models.py` is saved
- Restart Python interpreter/terminal

### Migration fails with "uuid-ossp" error
- PostgreSQL uuid extension required
- Make sure PostgreSQL is running: `docker-compose ps` in postgres folder

### Cannot connect to database
- Check PostgreSQL health: `docker-compose logs db` in postgres folder
- Verify credentials in `alembic.ini`

### Partial index syntax error
- Requires PostgreSQL 9.2+
- Error is normal if using older PostgreSQL version (ignore in downgrade)

---

For complete Alembic commands, see: `ALEMBIC_QUICKREF.md`
