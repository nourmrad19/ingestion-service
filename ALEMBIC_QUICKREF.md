# Alembic Quick Reference

## Initial Setup

**PowerShell (Windows):**
```powershell
# Start PostgreSQL and pgAdmin
cd postgres; docker-compose up -d; cd ..

# Install dependencies
pip install -r requirements.txt

# Run migrations (create tables)
alembic upgrade head
```

**Command Prompt or Bash:**
```bash
# Start PostgreSQL and pgAdmin
cd postgres && docker-compose up -d && cd ..

# Install dependencies
pip install -r requirements.txt

# Run migrations (create tables)
alembic upgrade head
```

## Daily Commands

### View Current State
```bash
alembic current              # Current migration version
alembic history              # All migration history
alembic history --verbose    # Detailed history
```

### After Modifying Models (app/models.py)

```bash
# Generate migration automatically
alembic revision --autogenerate -m "Add new column to users"

# Or create empty migration
alembic revision -m "Custom migration description"
```

### Apply Migrations

```bash
alembic upgrade head         # Apply all pending
alembic upgrade +1           # Apply next 1
alembic upgrade +2           # Apply next 2
alembic upgrade 001_initial  # Apply specific
```

### Rollback Migrations

```bash
alembic downgrade -1         # Undo last migration
alembic downgrade base       # Undo all
alembic downgrade -2         # Undo last 2
```

### Preview SQL Before Running

```bash
alembic upgrade head --sql   # See SQL without applying
alembic downgrade -1 --sql   # See rollback SQL
```

## pgAdmin Access

- **URL**: http://localhost:5050
- **Email**: admin@example.com
- **Password**: admin

### Add PostgreSQL Server in pgAdmin

1. Right-click "Servers" → Register → Server
2. **General tab:**
   - Name: `postgres_ingestion`
3. **Connection tab:**
   - Hostname/address: `postgres_db_ingestion` (or `localhost`)
   - Port: `5432`
   - Maintenance database: `postgres`
   - Username: `user`
   - Password: `password`
4. Click "Save"

### View Tables in pgAdmin

1. Navigate: Servers → databases → mydatabase → Schemas → public → Tables
2. You'll see:
   - `alembic_version` - tracks applied migrations
   - `users` - from your models
   - `documents` - from your models

## Migration File Structure

Each migration consists of:

```python
revision = '001_initial'      # Unique identifier
down_revision = None          # Previous migration (None if first)

def upgrade():               # Apply changes
    op.create_table(...)
    op.add_column(...)

def downgrade():             # Revert changes
    op.drop_table(...)
    op.drop_column(...)
```

## Common Model Changes → Migrations

### Add Column
```python
# Model
new_field = db.Column(db.String(100))

# Generated migration
def upgrade():
    op.add_column('table_name', sa.Column('new_field', sa.String(100)))
def downgrade():
    op.drop_column('table_name', 'new_field')
```

### Add Relationship
```python
# Model with ForeignKey (usually auto-detected)
user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

# Generated migration
def upgrade():
    op.add_column('documents', sa.Column('user_id', sa.Integer()))
    op.create_foreign_key('fk_documents_user', 'documents', 'users', ['user_id'], ['id'])
```

### Make Column Required
```python
# Model
name = db.Column(db.String(100), nullable=False)

# Generated migration modifies nullable
def upgrade():
    op.alter_column('users', 'name', existing_type=sa.String(100), nullable=False)
```

### Add Unique Constraint
```python
# Model
email = db.Column(db.String(100), unique=True)

# Generated migration
def upgrade():
    op.create_unique_constraint('uq_users_email', 'users', ['email'])
```

## Workflow Example: Add Email Verification

1. **Modify Model** (`app/models.py`):
   ```python
   class User(db.Model):
       email_verified = db.Column(db.Boolean, default=False)
       verified_at = db.Column(db.DateTime)
   ```

2. **Generate Migration**:
   ```bash
   alembic revision --autogenerate -m "Add email verification to users"
   ```
   Creates: `migrations/versions/002_add_email_verification.py`

3. **Review Migration** (optional):
   ```bash
   alembic upgrade head --sql
   ```

4. **Apply Migration**:
   ```bash
   alembic upgrade head
   ```

5. **Verify in pgAdmin**:
   - Open pgAdmin
   - Right-click `users` table → Properties
   - See new columns: `email_verified`, `verified_at`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "can't connect to postgres" | Check `docker-compose ps`, ensure db is running |
| "alembic: command not found" | Install: `pip install alembic sqlalchemy` |
| "Migration conflicts" | Use `alembic history --verbose` to diagnose |
| "pgAdmin won't connect" | Use `postgres_db_ingestion` as hostname, not `localhost` |
| "Revisions in wrong order" | Don't edit completed migrations, create new ones |

## Notes

- ✅ Always commit migrations to version control
- ✅ Review auto-generated migrations before applying
- ✅ Test migrations on dev before production
- ❌ Never modify completed migrations
- ❌ Don't skip migration versions

---

For detailed info, see: `ALEMBIC_SETUP.md`
