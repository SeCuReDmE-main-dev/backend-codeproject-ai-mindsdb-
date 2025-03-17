import psycopg2
from pymongo import MongoClient
import sqlite3
import logging
from pathlib import Path
from config.database import POSTGRESQL_CONFIG, MONGODB_CONFIG, SQLITE_CONFIG
from utils.port_checker import check_required_ports, find_available_port

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatabaseManager:
    def __init__(self):
        self.port_status = check_required_ports()
        self.connections = {}
        
    def setup_postgresql(self):
        try:
            if not self.port_status['PostgreSQL']['in_use']:
                logger.warning("PostgreSQL is not running on port 5432")
                return False
                
            conn = psycopg2.connect(
                dbname=POSTGRESQL_CONFIG['database'],
                user=POSTGRESQL_CONFIG['user'],
                password=POSTGRESQL_CONFIG['password'],
                host=POSTGRESQL_CONFIG['host'],
                port=POSTGRESQL_CONFIG['port']
            )
            self.connections['postgresql'] = conn
            logger.info("Successfully connected to PostgreSQL")
            return True
        except Exception as e:
            logger.error(f"PostgreSQL connection error: {str(e)}")
            return False

    def setup_mongodb(self):
        try:
            if not self.port_status['MongoDB']['in_use']:
                logger.warning("MongoDB is not running on port 27017")
                return False
                
            client = MongoClient(
                host=MONGODB_CONFIG['host'],
                port=MONGODB_CONFIG['port']
            )
            db = client[MONGODB_CONFIG['database']]
            self.connections['mongodb'] = db
            logger.info("Successfully connected to MongoDB")
            return True
        except Exception as e:
            logger.error(f"MongoDB connection error: {str(e)}")
            return False

    def setup_sqlite(self):
        try:
            db_path = Path(SQLITE_CONFIG['database'])
            conn = sqlite3.connect(db_path)
            self.connections['sqlite'] = conn
            logger.info("Successfully connected to SQLite")
            return True
        except Exception as e:
            logger.error(f"SQLite connection error: {str(e)}")
            return False

    def initialize_all(self):
        """Initialize all database connections"""
        results = {
            'postgresql': self.setup_postgresql(),
            'mongodb': self.setup_mongodb(),
            'sqlite': self.setup_sqlite()
        }
        
        # Log overall status
        for db_type, success in results.items():
            status = "SUCCESS" if success else "FAILED"
            logger.info(f"{db_type.upper()} Connection: {status}")
        
        return results

    def close_all(self):
        """Close all database connections"""
        for db_type, conn in self.connections.items():
            try:
                if db_type in ['postgresql', 'sqlite']:
                    conn.close()
                elif db_type == 'mongodb':
                    conn.client.close()
                logger.info(f"Closed {db_type} connection")
            except Exception as e:
                logger.error(f"Error closing {db_type} connection: {str(e)}")

if __name__ == "__main__":
    db_manager = DatabaseManager()
    results = db_manager.initialize_all()
    
    # Keep connections open if all successful, otherwise close
    if not all(results.values()):
        logger.warning("Some connections failed. Closing all connections.")
        db_manager.close_all()