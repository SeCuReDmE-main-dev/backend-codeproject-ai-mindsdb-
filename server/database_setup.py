import sqlite3
from contextlib import contextmanager

@contextmanager
def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file)
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
        "python": """
            CREATE TABLE IF NOT EXISTS python (
                id integer PRIMARY KEY,
                name text NOT NULL,
                code text NOT NULL
            )
        """,
        "javascript": """
            CREATE TABLE IF NOT EXISTS javascript (
                id integer PRIMARY KEY,
                name text NOT NULL,
                code text NOT NULL
            )
        """,
        "other": """
            CREATE TABLE IF NOT EXISTS other (
                id integer PRIMARY KEY,
                name text NOT NULL,
                code text NOT NULL
            )
        """
    }

    with create_connection(database) as conn:
        if conn is not None:
            for table_name, create_table_sql in tables.items():
                create_table(conn, create_table_sql)
                print(f"Created table: {table_name}")
        else:
            print("Error! Cannot create the database connection.")

if __name__ == '__main__':
    main()
