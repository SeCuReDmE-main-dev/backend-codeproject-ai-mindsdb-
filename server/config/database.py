"""Database configuration settings"""
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# PostgreSQL Configuration
POSTGRESQL_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'Neural_Network',
    'user': 'jean-sebastien',
    'password': os.getenv('POSTGRES_PASSWORD', '')  # Get password from environment variable
}

# MongoDB Configuration
MONGODB_CONFIG = {
    'host': 'localhost',
    'port': 27017,
    'database': 'Neural_Network'
}

# MindsDB Configuration
MINDSDB_CONFIG = {
    'mongo_api_port': 47337,
    'mongo_api_host': 'localhost'
}

# SQLite Configuration (as fallback)
SQLITE_CONFIG = {
    'database': 'shared_central_database.db'
}