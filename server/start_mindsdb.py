from mindsdb.api.mongo.server import run_mongo_server
from mindsdb.interfaces.database.database import DatabaseController
from mindsdb.utilities.config import Config

def start_mindsdb_mongo_api():
    try:
        # Initialize MindsDB configuration
        config = Config()
        
        # Set up the MongoDB API configuration
        config.override({
            'api': {
                'mongodb': {
                    'host': 'localhost',
                    'port': 47337
                }
            }
        })
        
        # Initialize database controller
        db = DatabaseController(config)
        
        print("Starting MindsDB MongoDB API on port 47337...")
        run_mongo_server('localhost', 47337)
        
    except Exception as e:
        print(f"Error starting MindsDB MongoDB API: {str(e)}")
        print("Please ensure MindsDB is properly installed and configured")

if __name__ == "__main__":
    start_mindsdb_mongo_api()