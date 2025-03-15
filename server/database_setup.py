import sqlite3
from contextlib import contextmanager
import json

@contextmanager
def create_connection(db_file):
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

def create_table(conn, create_table_sql):
    try:
        c = conn.cursor()
        c.execute(create_table_sql)
        conn.commit()
    except sqlite3.Error as e:
        print(f"Error creating table: {e}")

def main():
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

    with create_connection(database) as conn:
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

def insert_sample_data(database):
    with create_connection(database) as conn:
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

if __name__ == '__main__':
    main()
    # Uncomment the following line to insert sample data
    # insert_sample_data("shared_central_database.db")
