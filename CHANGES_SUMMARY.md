# Models Update Summary - What Changed and Why

## 🔄 Architecture Change: SQLAlchemy 2.0 Modernization

You've upgraded from **Flask-SQLAlchemy with Integer IDs** to **Modern SQLAlchemy 2.0 with UUID and Enterprise Features**.

---

## 📊 Before vs After Comparison

### Before (Old Schema)
```python
# app/models.py - Old approach
from app.database import db

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Document(db.Model):
    __tablename__ = 'documents'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    content = db.Column(db.Text)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
```

**Database:**
```
users (2 columns: id, name, email, timestamps)
documents (5 columns: id, title, content, user_id, timestamps)
```

### After (New Schema)
```python
# app/models.py - New approach
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy.dialects.postgresql import UUID, JSONB

class Base(DeclarativeBase):
    pass

class Document(Base):
    __tablename__ = "documents"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, server_default=text("uuid_generate_v4()"))
    tenant_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False, index=True)
    uploaded_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), index=True)
    created_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    updated_by: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True))
    filename: Mapped[str] = mapped_column(String(255), nullable=False)
    storage_path: Mapped[str] = mapped_column(String(500), nullable=False)
    file_size: Mapped[int | None] = mapped_column(Integer)
    mime_type: Mapped[str | None] = mapped_column(String(100))
    language: Mapped[str | None] = mapped_column(String(10), index=True)
    status: Mapped[str] = mapped_column(String(50), nullable=False, server_default="pending", index=True)
    metadata_json: Mapped[dict] = mapped_column(JSONB, server_default=text("'{}'::jsonb"))
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, server_default=text("false"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=text("now()"), index=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, server_default=text("now()")
```

**Database:**
```
documents (15 columns: id, tenant_id, uploaded_by, created_by, updated_by, 
           filename, storage_path, file_size, mime_type, language, 
           status, metadata_json, is_deleted, created_at, updated_at)
+ 6 indexes for performance
```

---

## 📝 File Changes

### 1. **app/database.py** - From Flask-SQLAlchemy to SQLAlchemy Core
```diff
- from flask_sqlalchemy import SQLAlchemy
- db = SQLAlchemy()

+ from sqlalchemy.orm import DeclarativeBase, Session
+ from sqlalchemy import create_engine
+
+ class Base(DeclarativeBase):
+     pass
+
+ db_engine = None
+ db_session = None
+
+ def init_db(database_url: str):
+     global db_engine, db_session
+     db_engine = create_engine(database_url, echo=False)
+     db_session = Session(db_engine)
+     return db_engine, db_session
```

**Why?**
- ✅ More control over database connection
- ✅ Works with Alembic seamlessly
- ✅ No Flask dependency for pure DB operations
- ✅ Better performance and flexibility

### 2. **app/models.py** - Complete Rewrite for Modern SQLAlchemy

| Aspect | Old | New |
|--------|-----|-----|
| **Base Class** | `db.Model` | `DeclarativeBase` |
| **ID Type** | Integer (1, 2, 3...) | UUID (550e8400-e29b-41d4-a716-446655440000) |
| **Multi-tenancy** | Not supported | ✅ `tenant_id` field |
| **Audit Trail** | Timestamps only | ✅ `created_by`, `updated_by` |
| **Flexible Data** | Fixed schema | ✅ JSONB `metadata_json` |
| **Soft Deletes** | Hard delete only | ✅ `is_deleted` flag |
| **Type Hints** | None | ✅ Full type annotations |
| **Indexes** | Manual | ✅ Automatic at column level |

### 3. **app/__init__.py** - Simplified Flask Setup
```diff
- from app.database import db
- db.init_app(app)

+ # Database initialized separately
+ # Flask focuses only on HTTP routes
```

### 4. **migrations/env.py** - Updated for New Base Class
```diff
- from app.database import db
- target_metadata = db.metadata

+ from app.database import Base
+ target_metadata = Base.metadata
```

### 5. **migrations/versions/001_initial.py** - New Migration
- Replaced old User/Document schema
- Creates UUID extension in PostgreSQL
- Creates new documents table with 15 columns
- Creates 6 performance indexes
- Supports soft deletes with partial indexing

---

## 🎯 Key Improvements

### 1. **UUID Instead of Sequential Integers**
```
Old: Document ID = 1, 2, 3 (predictable, sequential)
New: Document ID = 550e8400-e29b-41d4-a716-446655440000 (unpredictable, unique)

Benefits:
✅ Can't guess valid document IDs
✅ Works across microservices
✅ Better for distributed systems
✅ No ID collision in merged datasets
```

### 2. **Multi-Tenancy Ready**
Every document has a `tenant_id`, enabling SaaS architecture:
```python
# Automatically scoped to tenant
docs = session.query(Document).filter_by(
    tenant_id=tenant_id,  # Data isolation
    is_deleted=False
).all()
```

### 3. **Complete Audit Trail**
Track who did what:
```python
doc = Document(
    created_by=user_1_id,   # Who created
    uploaded_by=user_2_id,  # Who uploaded
    updated_by=user_3_id    # Who last modified
)
```

### 4. **Flexible Metadata with JSONB**
No schema migration needed for new fields:
```python
doc.metadata_json = {
    "pages": 15,
    "author": "John",
    "keywords": ["report", "analysis"],
    "custom_field": "any value",
    "nested": {"data": 123}  # Any structure
}
```

### 5. **Soft Deletes**
Recover deleted data and maintain audit trail:
```python
# Don't delete, mark as deleted
doc.is_deleted = True

# Query only active documents
active_docs = session.query(Document).filter_by(is_deleted=False).all()

# Find deleted
deleted_docs = session.query(Document).filter_by(is_deleted=True).all()
```

### 6. **Performance Optimized**
6 indexes created for common query patterns:
- `tenant_id` - Filter by organization
- `uploaded_by` - Find user's uploads
- `language` - Filter by language
- `status` - Filter by processing status
- `created_at` - Range queries
- `is_deleted` - Partial index (only non-deleted)

---

## 🚀 What to Do Now

### Step 1: Install Dependencies (if not done)
```powershell
pip install -r requirements.txt
```

Required packages:
- `SQLAlchemy==2.0.23` (new)
- `psycopg2-binary==2.9.9` (PostgreSQL driver)
- `alembic==1.13.1` (migrations)
- `Flask==3.0.0` (web framework)

### Step 2: Ensure PostgreSQL is Running
```powershell
cd postgres; docker-compose up -d; cd ..
```

Check status:
```powershell
cd postgres; docker-compose ps; cd ..
```

### Step 3: Apply Migration to Create Tables
```powershell
alembic upgrade head
```

This will:
1. Enable UUID extension in PostgreSQL
2. Create documents table with all 15 columns
3. Create 6 performance indexes
4. Record migration in `alembic_version` table

### Step 4: Verify in pgAdmin

1. Open http://localhost:5050
2. Login: `admin@example.com` / `admin`
3. Right-click "Servers" → Register → Server
4. Configure:
   - Name: `postgres_ingestion`
   - Hostname: `postgres_db_ingestion`
   - Port: `5432`
   - Username: `user`
   - Password: `password`
5. Navigate: Servers → mydatabase → Tables → documents
6. **Right-click documents → View/Edit Data**
7. **See the new schema!**

---

## 📋 Column Reference

### Identity & Multi-tenancy
- `id` (UUID) - Primary key, auto-generated
- `tenant_id` (UUID) - Organization/tenant identifier

### Actors (Audit Trail)
- `uploaded_by` (UUID) - Who uploaded the file
- `created_by` (UUID) - Who created the record
- `updated_by` (UUID) - Who last modified

### File Details
- `filename` (String) - Original filename
- `storage_path` (String) - Where file is stored
- `file_size` (Integer) - File size in bytes
- `mime_type` (String) - Content type
- `language` (String) - Detected language code

### Processing
- `status` (String) - pending/processing/completed/failed
- `metadata_json` (JSONB) - Flexible JSON data

### Lifecycle
- `is_deleted` (Boolean) - Soft delete flag
- `created_at` (DateTime) - Creation timestamp
- `updated_at` (DateTime) - Update timestamp

---

## 🔍 Indexing Strategy

```sql
-- Indexes created for you:
CREATE INDEX ix_documents_tenant_id ON documents(tenant_id);      -- Filter by tenant
CREATE INDEX ix_documents_uploaded_by ON documents(uploaded_by);  -- Find user uploads
CREATE INDEX ix_documents_language ON documents(language);        -- Filter by language
CREATE INDEX ix_documents_status ON documents(status);            -- Filter by status
CREATE INDEX ix_documents_created_at ON documents(created_at);    -- Range queries
CREATE INDEX ix_documents_is_deleted ON documents(is_deleted)     -- Partial: only WHERE is_deleted=false
  WHERE is_deleted = false;
```

**Result:** Queries are fast even with millions of documents!

---

## 📚 Documentation

- **MODELS_GUIDE.md** - How to use the new models
- **ALEMBIC_SETUP.md** - Complete Alembic setup guide
- **ALEMBIC_QUICKREF.md** - Quick reference for common commands

---

## ⚠️ Breaking Changes from Old Code

If you have existing code using old models:

```python
# ❌ OLD - Won't work
from app.models import User
doc = Document(user_id=1, title="Report", content="...")

# ✅ NEW - Works
from app.models import Document
import uuid
tenant_id = uuid.uuid4()
doc = Document(
    tenant_id=tenant_id,
    filename="report.pdf",
    storage_path="s3://bucket/report.pdf",
    status="pending"
)
```

---

## 🎓 What You Learned

| Concept | Old | New |
|---------|-----|-----|
| **PK Type** | Integer | UUID (distributed-safe) |
| **Tenancy** | None (single-tenant) | Built-in (multi-tenant) |
| **Audit** | Timestamps only | Full audit trail (who/when) |
| **Flexibility** | Fixed columns | JSONB for extras |
| **Soft Deletes** | Not possible | True/false flag |
| **Type Safety** | No hints | Python type annotations |
| **DB Init** | Flask-SQLAlchemy | Raw SQLAlchemy + Alembic |

---

## 🔗 Next Steps

1. ✅ Deploy migration: `alembic upgrade head`
2. ✅ Verify in pgAdmin
3. ⏭️ Update your business logic to use new Document model
4. ⏭️ Create REST API endpoints for document management
5. ⏭️ Implement search using JSONB metadata
6. ⏭️ Add soft delete queries to your code

---

## 💡 Pro Tips

### Tip 1: Always Query Active Documents
```python
# Include is_deleted filter in all queries
docs = session.query(Document).filter_by(
    tenant_id=tenant_id,
    is_deleted=False  # Don't forget this!
).all()
```

### Tip 2: Use JSONB for Flexible Fields
```python
# Add custom fields without migrations
doc.metadata_json = {"ocr_text": "extracted text", "confidence": 0.95}
session.commit()
```

### Tip 3: Track Changes
```python
# Always set updated_by when modifying
doc.updated_by = current_user_id
session.commit()
```

### Tip 4: UUID Generation
```python
import uuid

tenant_id = uuid.uuid4()  # Generate new UUID
user_id = uuid.UUID('550e8400-e29b-41d4-a716-446655440000')  # From string

# Always use UUID, not integer IDs
```

---

**Summary:** Your database is now enterprise-ready with UUIDs, multi-tenancy, audit trails, and flexible metadata! 🚀
