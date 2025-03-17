import sqlite3
from contextlib import contextmanager
import json
import psycopg2
from pymongo import MongoClient
import os
from sqlalchemy import create_engine, Column, Integer, String, DateTime, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Database Configuration
POSTGRESQL_CONFIG = {
    'host': 'localhost',
    'database': 'Neural_Network',  # Updated to match Compass config
    'user': 'postgres',
    'password': os.getenv('POSTGRES_PASSWORD'),
    'port': '5432'
}

MONGODB_CONFIG = {
    'host': 'localhost',
    'port': 27017,  # Updated to match Compass config
    'database': 'mindsdb',
    'connection_string': 'mongodb://localhost:27017/'  # Added from Compass config
}

MINDSDB_CONFIG = {
    'host': '127.0.0.1',
    'port': 47336,
    'database': 'mindsdb',
    'api': {
        'mongo': {
            'path': 'C:/Users/jeans/OneDrive/Desktop/SeCuReDmE final/SeCuReDmE-1/mini-app-codeproject-ai-mindsdb/MindsDB/mindsdb/api/mongo',
            'port': 47337,
            'host': '127.0.0.1'
        },
        'postgres': {
            'path': 'C:/Users/jeans/OneDrive/Desktop/SeCuReDmE final/SeCuReDmE-1/mini-app-codeproject-ai-mindsdb/MindsDB/mindsdb/api/postgres/postgres_proxy',
            'port': 47335,
            'host': '127.0.0.1',
            'user': 'postgres',
            'password': 'your_password',
            'database': 'mindsdb'
        }
    }
}

# Create the database directory if it doesn't exist
os.makedirs('database', exist_ok=True)

# Create a database engine
engine = create_engine('sqlite:///database/app.db', echo=True)

# Create a base class for our models
Base = declarative_base()

# Define the AI Models table
class AIModel(Base):
    __tablename__ = 'ai_models'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    status = Column(String(20), default='active')
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    def __repr__(self):
        return f"<AIModel(name='{self.name}', status='{self.status}')>"

# Create all tables
def setup_database():
    Base.metadata.create_all(engine)
    print("Database tables created successfully.")
    
    # Create a session to add some initial data if needed
    Session = sessionmaker(bind=engine)
    session = Session()
    
    # Check if we have any models already
    existing_models = session.query(AIModel).count()
    
    if existing_models == 0:
        # Add some sample models
        sample_models = [
            AIModel(name="CodeProject.AI Object Detection", 
                   description="Detects objects in images using YOLO"),
            AIModel(name="MindsDB Text Prediction", 
                   description="AI-powered text prediction model")
        ]
        
        session.add_all(sample_models)
        session.commit()
        print("Sample data added to the database.")
    
    session.close()

if __name__ == "__main__":
    setup_database()
    print("Database setup complete. The 'ai_models' table has been created.")

@contextmanager
def create_sqlite_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        conn.row_factory = sqlite3.Row  # Enable row factory for dictionary-like access
        print(f"Connected to {db_file}")
        yield conn
    except sqlite3.Error as e:
        print(f"Error connecting to database: {e}")
        yield None
    finally:
        if conn:
            conn.close()

@contextmanager
def create_postgres_connection():
    conn = None
    try:
        conn = psycopg2.connect(**POSTGRESQL_CONFIG)
        print(f"Connected to PostgreSQL database")
        yield conn
    except Exception as e:
        print(f"Error connecting to PostgreSQL database: {e}")
        yield None
    finally:
        if conn:
            conn.close()

@contextmanager
def create_mongodb_connection():
    client = None
    try:
        # Using the connection string from Compass config
        client = MongoClient(MONGODB_CONFIG['connection_string'])
        db = client[MONGODB_CONFIG['database']]
        print(f"Connected to MongoDB database at {MONGODB_CONFIG['connection_string']}")
        yield db
    except Exception as e:
        print(f"Error connecting to MongoDB database: {e}")
        yield None
    finally:
        if client is not None:
            client.close()

def initialize_mindsdb_apis():
    """Initialize MindsDB API paths and configurations"""
    try:
        # Set environment variables for API paths
        os.environ['MINDSDB_MONGO_API_PATH'] = MINDSDB_CONFIG['api']['mongo']['path']
        os.environ['MINDSDB_POSTGRES_API_PATH'] = MINDSDB_CONFIG['api']['postgres']['path']
        
        # Create MongoDB proxy configuration
        mongo_config = {
            'host': MINDSDB_CONFIG['api']['mongo']['host'],
            'port': MINDSDB_CONFIG['api']['mongo']['port'],
            'api_path': MINDSDB_CONFIG['api']['mongo']['path']
        }
        
        # Create PostgreSQL proxy configuration
        postgres_config = {
            'host': MINDSDB_CONFIG['api']['postgres']['host'],
            'port': MINDSDB_CONFIG['api']['postgres']['port'],
            'user': MINDSDB_CONFIG['api']['postgres']['user'],
            'password': MINDSDB_CONFIG['api']['postgres']['password'],
            'database': MINDSDB_CONFIG['api']['postgres']['database'],
            'api_path': MINDSDB_CONFIG['api']['postgres']['path']
        }
        
        # Save proxy configurations
        config_dir = os.path.dirname(MINDSDB_CONFIG['api']['mongo']['path'])
        
        with open(os.path.join(config_dir, 'mongo_config.json'), 'w') as f:
            json.dump(mongo_config, f, indent=4)
            
        with open(os.path.join(config_dir, 'postgres_config.json'), 'w') as f:
            json.dump(postgres_config, f, indent=4)
            
        print("MindsDB API configurations initialized successfully")
        return True
    except Exception as e:
        print(f"Error initializing MindsDB APIs: {e}")
        return False

@contextmanager
def create_mindsdb_connection():
    client = None
    try:
        # Initialize MindsDB APIs before connection
        if initialize_mindsdb_apis():
            mongo_port = MINDSDB_CONFIG['api']['mongo']['port']
            client = MongoClient(f"mongodb://{MINDSDB_CONFIG['host']}:{mongo_port}/")
            db = client[MINDSDB_CONFIG['database']]
            print(f"Connected to MindsDB through MongoDB API on port {mongo_port}")
            yield db
        else:
            print("Failed to initialize MindsDB APIs")
            yield None
    except Exception as e:
        print(f"Error connecting to MindsDB: {e}")
        yield None
    finally:
        if client:
            client.close()

def create_table(conn, create_table_sql):
    try:
        c = conn.cursor()
        c.execute(create_table_sql)
        conn.commit()
    except sqlite3.Error as e:
        print(f"Error creating table: {e}")

def create_postgres_tables(conn):
    try:
        with conn.cursor() as cursor:
            # Create AI models table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS ai_models (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    description TEXT NOT NULL,
                    status VARCHAR(50) DEFAULT 'pending',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Create predictions table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS predictions (
                    id SERIAL PRIMARY KEY,
                    model_id INTEGER NOT NULL,
                    input_data JSONB NOT NULL,
                    output_data JSONB NOT NULL,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (model_id) REFERENCES ai_models (id)
                )
            """)
            
            # Create update trigger for updated_at
            cursor.execute("""
                CREATE OR REPLACE FUNCTION update_updated_at_column()
                RETURNS TRIGGER AS $$
                BEGIN
                    NEW.updated_at = CURRENT_TIMESTAMP;
                    RETURN NEW;
                END;
                $$ language 'plpgsql';
            """)
            
            cursor.execute("""
                DROP TRIGGER IF EXISTS update_ai_models_updated_at ON ai_models;
                CREATE TRIGGER update_ai_models_updated_at
                    BEFORE UPDATE ON ai_models
                    FOR EACH ROW
                    EXECUTE FUNCTION update_updated_at_column();
            """)
            
        conn.commit()
        print("PostgreSQL tables created successfully")
    except Exception as e:
        print(f"Error creating PostgreSQL tables: {e}")

def create_mongodb_collections(db):
    try:
        # Create collections if they don't exist
        if "ai_models" not in db.list_collection_names():
            db.create_collection("ai_models")
        
        if "predictions" not in db.list_collection_names():
            db.create_collection("predictions")
            
        # Create indexes
        db.ai_models.create_index("name")
        db.predictions.create_index("model_id")
        
        print("MongoDB collections created successfully")
    except Exception as e:
        print(f"Error creating MongoDB collections: {e}")

def main():
    # Initialize SQLite
    database = "shared_central_database.db"
    
    tables = {
        "ai_models": """
            CREATE TABLE IF NOT EXISTS ai_models (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT NOT NULL,
                status TEXT DEFAULT 'pending',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """,
        "predictions": """
            CREATE TABLE IF NOT EXISTS predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                model_id INTEGER NOT NULL,
                input_data TEXT NOT NULL,
                output_data TEXT NOT NULL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (model_id) REFERENCES ai_models (id)
            )
        """,
        "python": """
            CREATE TABLE IF NOT EXISTS python (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                code TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """,
        "javascript": """
            CREATE TABLE IF NOT EXISTS javascript (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                code TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """,
        "other": """
            CREATE TABLE IF NOT EXISTS other (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                code TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """
    }

    with create_sqlite_connection(database) as conn:
        if conn is not None:
            for table_name, create_table_sql in tables.items():
                create_table(conn, create_table_sql)
                print(f"Created table: {table_name}")
            
            # Create triggers for updated_at timestamp
            trigger_sql = """
                CREATE TRIGGER IF NOT EXISTS update_ai_models_timestamp 
                AFTER UPDATE ON ai_models
                BEGIN
                    UPDATE ai_models SET updated_at = CURRENT_TIMESTAMP 
                    WHERE id = NEW.id;
                END;
            """
            create_table(conn, trigger_sql)
        else:
            print("Error! Cannot create the database connection.")

    # Initialize PostgreSQL
    with create_postgres_connection() as pg_conn:
        if pg_conn is not None:
            create_postgres_tables(pg_conn)

    # Initialize MongoDB
    with create_mongodb_connection() as mongo_db:
        if mongo_db is not None:
            create_mongodb_collections(mongo_db)

    # Initialize MindsDB APIs and test connection
    print("\nInitializing MindsDB APIs...")
    with create_mindsdb_connection() as mindsdb:
        if mindsdb is not None:
            print("Successfully connected to MindsDB")
            print(f"MongoDB API path: {MINDSDB_CONFIG['api']['mongo']['path']}")
            print(f"PostgreSQL API path: {MINDSDB_CONFIG['api']['postgres']['path']}")

def insert_sample_data(database):
    with create_sqlite_connection(database) as conn:
        if conn is not None:
            try:
                # Insert sample AI model
                c = conn.cursor()
                c.execute("""
                    INSERT INTO ai_models (name, description, status)
                    VALUES (?, ?, ?)
                """, ('Sample Model', 'A sample AI model for testing', 'active'))
                
                model_id = c.lastrowid
                
                # Insert sample prediction
                c.execute("""
                    INSERT INTO predictions (model_id, input_data, output_data)
                    VALUES (?, ?, ?)
                """, (
                    model_id,
                    json.dumps({'input': 'test_input'}),
                    json.dumps({'prediction': 'test_output'})
                ))
                
                conn.commit()
                print("Sample data inserted successfully")
            except sqlite3.Error as e:
                print(f"Error inserting sample data: {e}")
        else:
            print("Error! Cannot create the database connection.")
    
    # Insert PostgreSQL sample data
    with create_postgres_connection() as pg_conn:
        if pg_conn is not None:
            try:
                with pg_conn.cursor() as cursor:
                    cursor.execute("""
                        INSERT INTO ai_models (name, description, status)
                        VALUES (%s, %s, %s)
                        RETURNING id
                    """, ('Sample PostgreSQL Model', 'A sample PostgreSQL AI model', 'active'))
                    
                    model_id = cursor.fetchone()[0]
                    
                    cursor.execute("""
                        INSERT INTO predictions (model_id, input_data, output_data)
                        VALUES (%s, %s, %s)
                    """, (
                        model_id,
                        json.dumps({'input': 'test_input'}),
                        json.dumps({'prediction': 'test_output'})
                    ))
                    
                pg_conn.commit()
                print("PostgreSQL sample data inserted successfully")
            except Exception as e:
                print(f"Error inserting PostgreSQL sample data: {e}")

    # Insert MongoDB sample data
    with create_mongodb_connection() as mongo_db:
        if mongo_db is not None:
            try:
                model = {
                    'name': 'Sample MongoDB Model',
                    'description': 'A sample MongoDB AI model',
                    'status': 'active',
                    'created_at': datetime.datetime.utcnow(),
                    'updated_at': datetime.datetime.utcnow()
                }
                
                result = mongo_db.ai_models.insert_one(model)
                
                prediction = {
                    'model_id': result.inserted_id,
                    'input_data': {'input': 'test_input'},
                    'output_data': {'prediction': 'test_output'},
                    'timestamp': datetime.datetime.utcnow()
                }
                
                mongo_db.predictions.insert_one(prediction)
                print("MongoDB sample data inserted successfully")
            except Exception as e:
                print(f"Error inserting MongoDB sample data: {e}")

if __name__ == '__main__':
    main()
    # Uncomment the following line to insert sample data
    # insert_sample_data("shared_central_database.db")
