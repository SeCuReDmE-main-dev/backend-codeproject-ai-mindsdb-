from database_setup import (
    create_mongodb_connection,
    create_postgres_connection,
    create_mindsdb_connection
)

def test_connections():
    print("Testing database connections...")
    
    # Test MongoDB
    print("\nTesting MongoDB connection:")
    with create_mongodb_connection() as mongo_db:
        try:
            collections = mongo_db.list_collection_names() if mongo_db is not None else []
            print(f"Available collections: {collections}")
        except Exception as e:
            print(f"Error listing collections: {e}")
    
    # Test PostgreSQL
    print("\nTesting PostgreSQL connection:")
    with create_postgres_connection() as pg_conn:
        if pg_conn is not None:
            try:
                with pg_conn.cursor() as cursor:
                    cursor.execute("SELECT current_database(), current_user;")
                    db, user = cursor.fetchone()
                    print(f"Connected to database: {db} as user: {user}")
            except Exception as e:
                print(f"Error querying PostgreSQL: {e}")
    
    # Test MindsDB
    print("\nTesting MindsDB connection:")
    with create_mindsdb_connection() as mindsdb:
        try:
            collections = mindsdb.list_collection_names() if mindsdb is not None else []
            print(f"Available MindsDB collections: {collections}")
        except Exception as e:
            print(f"Error connecting to MindsDB: {e}")

if __name__ == "__main__":
    test_connections()