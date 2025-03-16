import requests
import json
import os
import sys

def test_codeproject_ai():
    """Test the CodeProject AI server connection and a basic object detection request"""
    print("Testing CodeProject AI Server...")
    
    try:
        # Check server status
        response = requests.get("http://localhost:5000/api/status")
        if response.status_code == 200:
            print("✅ CodeProject AI Server is running")
            print(f"Server status: {response.json()}")
        else:
            print("❌ CodeProject AI Server is not responding correctly")
            return False
        
        # Test object detection (if you have an image)
        image_path = os.path.join(os.path.dirname(__file__), "test_image.jpg")
        if os.path.exists(image_path):
            with open(image_path, 'rb') as image_file:
                files = {'image': image_file}
                response = requests.post(
                    "http://localhost:5000/v1/vision/detection",
                    files=files
                )
                
                if response.status_code == 200:
                    print("✅ Object detection successful")
                    print(f"Detected objects: {response.json()}")
                else:
                    print(f"❌ Object detection failed: {response.text}")
        else:
            print("⚠️ No test image found, skipping object detection test")
            
        return True
        
    except Exception as e:
        print(f"❌ Error connecting to CodeProject AI Server: {str(e)}")
        return False

def test_mindsdb():
    """Test the MindsDB server connection and a basic query"""
    print("\nTesting MindsDB Server...")
    
    try:
        # Check MindsDB connection using the HTTP API
        response = requests.get("http://localhost:5001/api/status")
        if response.status_code == 200:
            print("✅ MindsDB Server is running")
        else:
            print("❌ MindsDB Server is not responding correctly")
            return False
        
        # Try a simple prediction (this is a generic example)
        query_data = {
            "query": "SELECT * FROM models LIMIT 5;"
        }
        
        response = requests.post(
            "http://localhost:5001/api/sql/query",
            json=query_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            print("✅ MindsDB query successful")
            print(f"Query result: {response.json()}")
        else:
            print(f"❌ MindsDB query failed: {response.text}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error connecting to MindsDB Server: {str(e)}")
        return False

def test_database():
    """Test the SQLite database connection"""
    print("\nTesting Database Connection...")
    
    try:
        import sqlite3
        
        # Connect to the SQLite database
        db_path = os.path.join(os.path.dirname(__file__), "server", "database", "app.db")
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if the ai_models table exists and has data
        cursor.execute("SELECT COUNT(*) FROM ai_models")
        count = cursor.fetchone()[0]
        
        if count > 0:
            print(f"✅ Database connection successful. Found {count} AI models.")
            
            # Get some sample data
            cursor.execute("SELECT id, name, description FROM ai_models LIMIT 3")
            models = cursor.fetchall()
            print("\nSample AI Models:")
            for model in models:
                print(f"  - {model[0]}: {model[1]} - {model[2]}")
        else:
            print("⚠️ Database connection successful but no AI models found.")
            
        conn.close()
        return True
        
    except sqlite3.OperationalError as e:
        if "no such table" in str(e):
            print("❌ Database error: ai_models table doesn't exist. Run the database setup script first.")
            print("   Run: python server/database_setup.py")
        else:
            print(f"❌ Database error: {str(e)}")
        return False
        
    except Exception as e:
        print(f"❌ Error connecting to database: {str(e)}")
        return False

def main():
    print("=" * 50)
    print("Mini App with CodeProject AI and MindsDB - Test Script")
    print("=" * 50)
    
    # Run tests
    db_ok = test_database()
    cp_ok = test_codeproject_ai()
    mb_ok = test_mindsdb()
    
    # Summary
    print("\n" + "=" * 50)
    print("Test Summary:")
    print(f"- Database: {'✅ OK' if db_ok else '❌ Failed'}")
    print(f"- CodeProject AI: {'✅ OK' if cp_ok else '❌ Failed'}")
    print(f"- MindsDB: {'✅ OK' if mb_ok else '❌ Failed'}")
    
    if db_ok and cp_ok and mb_ok:
        print("\n✅ All systems are operational! The mini app should work correctly.")
    else:
        print("\n❌ Some components are not working. Please fix the issues before using the app.")
        
    print("=" * 50)

if __name__ == "__main__":
    main()
