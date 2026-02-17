from sqlalchemy.orm import DeclarativeBase, Session
from sqlalchemy import create_engine
import os

class Base(DeclarativeBase):
    pass

# Database engine will be created in app factory
db_engine = None
db_session = None

def init_db(database_url: str):
    """Initialize database connection"""
    global db_engine, db_session
    db_engine = create_engine(database_url, echo=False)
    db_session = Session(db_engine)
    return db_engine, db_session

def get_session() -> Session:
    """Get database session"""
    return db_session
pip install -r requirements.txt
python -m app.main
# then open http://localhost:5000/health