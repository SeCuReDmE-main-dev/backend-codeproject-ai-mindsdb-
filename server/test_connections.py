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
        if mongo_db:
            collections = mongo_db.list_collection_names()
            print(f"Available collections: {collections}")
    
    # Test PostgreSQL
    print("\nTesting PostgreSQL connection:")
    with create_postgres_connection() as pg_conn:
        if pg_conn:
            with pg_conn.cursor() as cursor:
                cursor.execute("SELECT current_database(), current_user;")
                db, user = cursor.fetchone()
                print(f"Connected to database: {db} as user: {user}")
    
    # Test MindsDB
    print("\nTesting MindsDB connection:")
    with create_mindsdb_connection() as mindsdb:
        if mindsdb:
            collections = mindsdb.list_collection_names()
            print(f"Available MindsDB collections: {collections}")

if __name__ == "__main__":
    test_connections()