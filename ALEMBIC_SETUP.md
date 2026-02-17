# Database Migration Setup with Alembic

## Overview

This project uses **Alembic** for database migrations. Alembic is a lightweight database migration tool that works with SQLAlchemy ORM. It allows you to:

- **Track database schema changes** as Python scripts
- **Version control** your database schema
- **Roll back** to previous database states
- **Auto-generate** migration scripts from model changes
- **Maintain** synchronization between code and database

## Structure

```
ingestion-service/
├── app/                          # Python application
│   ├── __init__.py              # Flask app factory
│   ├── models.py                # SQLAlchemy ORM models
│   ├── database.py              # Database connection setup
│   └── main.py                  # Flask server entry point
├── migrations/                   # Alembic migration folder
│   ├── versions/                # Individual migration files
│   │   └── 001_initial.py       # First migration (create tables)
│   ├── env.py                   # Alembic environment config
│   └── script.py.mako           # Migration script template
├── postgres/                     # PostgreSQL + pgAdmin setup
│   └── docker-compose.yml       # Docker services config
├── alembic.ini                  # Alembic configuration
└── requirements.txt             # Python dependencies
```

## Key Components

### 1. **SQLAlchemy Models** (`app/models.py`)
Defines your database schema as Python classes:
- Models represent database tables
- Columns are defined as class attributes
- Relationships and constraints are specified in code
- Example: `User` and `Document` models

### 2. **Alembic Configuration** (`alembic.ini` & `migrations/env.py`)
- `alembic.ini`: Database connection string and settings
- `migrations/env.py`: Hooks into the migration process
- Automatically discovers your SQLAlchemy models

### 3. **Migration Files** (`migrations/versions/`)
Python scripts that describe database changes:
- `upgrade()`: Applies changes to the database
- `downgrade()`: Reverts changes
- Example: `001_initial.py` creates users and documents tables

### 4. **pgAdmin Interface** (Docker service)
Web UI to visualize and manage your database:
- View tables, columns, and data
- Execute SQL queries
- Monitor database activity

## Getting Started

### Step 1: Start PostgreSQL and pgAdmin

```bash
cd postgres
docker-compose up -d
```

This starts:
- **PostgreSQL** on `localhost:5432`
- **pgAdmin** on `localhost:5050`

### Step 2: Install Dependencies

```bash
pip install -r requirements.txt
```

### Step 3: Run Migrations

Run the initial migration to create tables:

```bash
alembic upgrade head
```

This:
1. Connects to PostgreSQL
2. Executes the `001_initial.py` migration
3. Creates `users` and `documents` tables
4. Records migration history in `alembic_version` table

### Step 4: Verify in pgAdmin

1. Open **pgAdmin**: http://localhost:5050
2. Login: `admin@example.com` / `admin`
3. Add Server:
   - Name: `postgres_ingestion`
   - Host: `postgres_db_ingestion` (or `localhost`)
   - Username: `user`
   - Password: `password`
4. Navigate: Servers → databases → mydatabase → Schemas → public → Tables
5. You should see:
   - `alembic_version` (tracks which migrations ran)
   - `documents` (stores documents)
   - `users` (stores users)

## Common Alembic Commands

### Create a New Migration
When you modify `models.py`, auto-generate the migration:

```bash
alembic revision --autogenerate -m "Add new_column to users table"
```

This creates a new file in `migrations/versions/` with your changes.

### Apply Migrations
```bash
alembic upgrade head        # Apply all pending migrations
alembic upgrade +1          # Apply next migration
alembic upgrade 001_initial # Apply specific migration
```

### Rollback Migrations
```bash
alembic downgrade -1        # Rollback last migration
alembic downgrade base      # Rollback to initial state
```

### View Migration History
```bash
alembic current     # Show current migration
alembic history     # Show all migrations
```

### Show Pending Migrations
```bash
alembic upgrade head --sql  # See SQL without applying
```

## How It Works

### The Synchronization Process

1. **You modify** `app/models.py` (e.g., add a new column)
2. **Alembic detects** the difference between models and database
3. **You generate** migration: `alembic revision --autogenerate -m "description"`
4. **Alembic creates** a new Python script with `upgrade()` and `downgrade()`
5. **You run** migrations: `alembic upgrade head`
6. **Database updates**: Tables are created/modified
7. **pgAdmin shows** the changes in real-time

### Example: Add Email Verification

```python
# models.py - Add to User model
email_verified = db.Column(db.Boolean, default=False)
```

Then run:
```bash
alembic revision --autogenerate -m "Add email_verified to users"
alembic upgrade head
```

Alembic automatically generates:
```python
# Migration file
def upgrade():
    op.add_column('users', sa.Column('email_verified', sa.Boolean(), default=False))

def downgrade():
    op.drop_column('users', 'email_verified')
```

## Why Alembic?

| Feature | Benefit |
|---------|---------|
| **Version Control** | Track DB changes like code changes |
| **Reproducibility** | Everyone gets same DB schema |
| **Rollback Support** | Revert changes if needed |
| **Auto-generation** | Less manual SQL writing |
| **Team Collaboration** | Merge-friendly Python migrations |
| **Audit Trail** | History of all schema changes |

## PostgreSQL + pgAdmin Integration

**PostgreSQL** (the database):
- Stores your data
- Runs on port 5432 (not accessible externally by default)
- Persists to Docker volume `postgres_data`

**pgAdmin** (the web UI):
- Accessible at http://localhost:5050
- Visually browse tables, columns, data
- Run SQL queries
- Monitor performance
- Create/edit SQL objects

## Next Steps

1. Install dependencies and run migrations
2. View tables in pgAdmin
3. Add new models to `app/models.py`
4. Generate migrations with `alembic revision --autogenerate`
5. Apply migrations and verify in pgAdmin
6. Run the Flask server: `python app/main.py`

## Troubleshooting

### Error: "can't connect to database"
- Check PostgreSQL is running: `docker-compose ps`
- Verify credentials in `alembic.ini` match `docker-compose.yml`
- Wait for PostgreSQL to start (check health)

### Error: "alembic command not found"
- Install: `pip install alembic`

### pgAdmin can't connect to PostgreSQL
- Use hostname: `postgres_db_ingestion` (Docker network)
- Port: `5432`
- Check PostgreSQL health status in Docker

### Migration conflicts
- Use `alembic history` to see migration order
- Never edit completed migrations
- Create new migrations for changes

---

**Summary**: Alembic keeps your code and database synchronized. Write Python models → Alembic generates SQL → Migrations are applied → pgAdmin confirms changes. This is the modern way to manage database schemas!
